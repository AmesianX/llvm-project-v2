//===--- JSONRPCDispatcher.h - Main JSON parser entry point -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANGD_JSONRPCDISPATCHER_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANGD_JSONRPCDISPATCHER_H

#include "Cancellation.h"
#include "Logger.h"
#include "Protocol.h"
#include "Trace.h"
#include "clang/Basic/LLVM.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/Support/JSON.h"
#include <iosfwd>
#include <mutex>

namespace clang {
namespace clangd {

/// Encapsulates output and logs streams and provides thread-safe access to
/// them.
class JSONOutput : public Logger {
  // FIXME(ibiryukov): figure out if we can shrink the public interface of
  // JSONOutput now that we pass Context everywhere.
public:
  JSONOutput(llvm::raw_ostream &Outs, llvm::raw_ostream &Logs,
             Logger::Level MinLevel, llvm::raw_ostream *InputMirror = nullptr,
             bool Pretty = false)
      : Pretty(Pretty), MinLevel(MinLevel), Outs(Outs), Logs(Logs),
        InputMirror(InputMirror) {}

  /// Emit a JSONRPC message.
  void writeMessage(const llvm::json::Value &Result);

  /// Write a line to the logging stream.
  void log(Level, const llvm::formatv_object_base &Message) override;

  /// Mirror \p Message into InputMirror stream. Does nothing if InputMirror is
  /// null.
  /// Unlike other methods of JSONOutput, mirrorInput is not thread-safe.
  void mirrorInput(const Twine &Message);

  // Whether output should be pretty-printed.
  const bool Pretty;

private:
  Logger::Level MinLevel;
  llvm::raw_ostream &Outs;
  llvm::raw_ostream &Logs;
  llvm::raw_ostream *InputMirror;

  std::mutex StreamMutex;
};

/// Sends a successful reply.
/// Current context must derive from JSONRPCDispatcher::Handler.
void reply(llvm::json::Value &&Result);
/// Sends an error response to the client, and logs it.
/// Current context must derive from JSONRPCDispatcher::Handler.
void replyError(ErrorCode Code, const llvm::StringRef &Message);
/// Implements ErrorCode and message extraction from a given llvm::Error. It
/// fetches the related message from error's message method. If error doesn't
/// match any known errors, uses ErrorCode::InvalidParams for the error.
void replyError(llvm::Error E);
/// Returns the request-id of the current request. Should not be used directly
/// for replying to requests, use the above mentioned methods for that case.
const llvm::json::Value *getRequestId();
/// Sends a request to the client.
/// Current context must derive from JSONRPCDispatcher::Handler.
void call(llvm::StringRef Method, llvm::json::Value &&Params);

/// Main JSONRPC entry point. This parses the JSONRPC "header" and calls the
/// registered Handler for the method received.
///
/// The `$/cancelRequest` notification is handled by the dispatcher itself.
/// It marks the matching request as cancelled, if it's still running.
class JSONRPCDispatcher {
public:
  /// A handler responds to requests for a particular method name.
  ///
  /// JSONRPCDispatcher will mark the handler's context as cancelled if a
  /// matching cancellation request is received. Handlers are encouraged to
  /// check for cancellation and fail quickly in this case.
  using Handler = std::function<void(const llvm::json::Value &)>;

  /// Create a new JSONRPCDispatcher. UnknownHandler is called when an unknown
  /// method is received.
  JSONRPCDispatcher(Handler UnknownHandler);

  /// Registers a Handler for the specified Method.
  void registerHandler(StringRef Method, Handler H);

  /// Parses a JSONRPC message and calls the Handler for it.
  bool call(const llvm::json::Value &Message, JSONOutput &Out);

private:
  // Tracking cancellations needs a mutex: handlers may finish on a different
  // thread, and that's when we clean up entries in the map.
  mutable std::mutex RequestCancelersMutex;
  llvm::StringMap<std::pair<Canceler, unsigned>> RequestCancelers;
  unsigned NextRequestCookie = 0;
  Context cancelableRequestContext(const llvm::json::Value &ID);
  void cancelRequest(const llvm::json::Value &ID);

  llvm::StringMap<Handler> Handlers;
  Handler UnknownHandler;
};

/// Controls the way JSON-RPC messages are encoded (both input and output).
enum JSONStreamStyle {
  /// Encoding per the LSP specification, with mandatory Content-Length header.
  Standard,
  /// Messages are delimited by a '---' line. Comment lines start with #.
  Delimited
};

/// Parses input queries from LSP client (coming from \p In) and runs call
/// method of \p Dispatcher for each query.
/// After handling each query checks if \p IsDone is set true and exits the loop
/// if it is.
/// Input stream(\p In) must be opened in binary mode to avoid preliminary
/// replacements of \r\n with \n.
/// We use C-style FILE* for reading as std::istream has unclear interaction
/// with signals, which are sent by debuggers on some OSs.
void runLanguageServerLoop(std::FILE *In, JSONOutput &Out,
                           JSONStreamStyle InputStyle,
                           JSONRPCDispatcher &Dispatcher, bool &IsDone);
} // namespace clangd
} // namespace clang

#endif
