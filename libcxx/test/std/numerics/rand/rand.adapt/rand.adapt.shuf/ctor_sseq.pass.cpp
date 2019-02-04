//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <random>

// template<class Engine, size_t k>
// class shuffle_order_engine

// template<class Sseq> explicit shuffle_order_engine(Sseq& q);

#include <random>
#include <sstream>
#include <cassert>

void
test1()
{
    const char* a = "1894661934 884942216 1899568837 1561547157 525417712 "
        "242729120 1476874187 1208468883 1983666902 1953485886 1507290666 "
        "1317123450 632390874 696850315 1734917114 218976032 1690682513 "
        "1944862534 456017951 2072049961 1348874775 1700965693 828093387 "
        "2071522749 1077957279 1055942061 413360419 238964088 475007126 "
        "1248050783 1516729632 1044035134 9617501 580065782 1737324341 "
        "2022534575 219953662 941840747 415472792 1381878747 200458524 "
        "1852054372 1849850586 1318041283 1026024576 101363422 660501483 "
        "705453438 298717379 1873705814 673416290 868766340 614560427 "
        "1668238166 532360730 969915708 1972423626 1966307090 97417947 "
        "920896215 588041576 495024338 522400288 1068491480 878048146 "
        "1995051285 17282737 560668414 2143274709 127339385 1299331283 "
        "99667038 66663006 1566161755 773555006 272986904 1065825536 "
        "1168683925 1185292013 1144552919 1489883454 811887358 279732868 "
        "628609193 1562647158 1833265343 1742736292 639398211 357562689 "
        "896869717 501615326 1775469607 1032409784 43371928 955037563 "
        "1023543663 1354331571 1071539244 562210166 138213162 1518791327 "
        "1335204647 1727874626 2114964448 1058152392 1055171537 348065433 "
        "190278003 399246038 1389247438 1639480282 382424917 2144508195 "
        "1531185764 1342593547 1359065400 1176108308 1412845568 968776497 "
        "5573525 1332437854 323541262 329396230 2097079291 1110029273 "
        "1071549822 739994612 1011644107 1074473050 478563727 894301674 "
        "290189565 280656618 1121689914 1630931232 579945916 1870220126 "
        "71516543 1535179528 1893792038 1107650479 1893348357 93154853 "
        "138035708 683805596 1535656875 1326628479 1469623399 1751042846 "
        "661214234 1947241260 1780560187 690441964 1403944207 1687457460 "
        "1428487938 1877084153 1618585041 1383427538 461185097 869443256 "
        "1254069404 1739961370 1245924391 138197640 1257913073 1915996843 "
        "641653536 1755587965 1889101622 1732723706 2009073422 1611621773 "
        "315899200 738279016 94909546 1711873548 1620302377 181922632 "
        "1704446343 1345319468 2076463060 357902023 157605314 1025175647 "
        "865799248 138769064 124418006 1591838311 675218651 1096276609 "
        "1858759850 732186041 769493777 735387805 894450150 638142050 "
        "720101232 1671055379 636619387 898507955 118193981 63865192 "
        "1787942091 204050966 2100684950 1580797970 1951284753 1020070334 "
        "960149537 1041144801 823914651 558983501 1742229329 708805658 "
        "804904097 1023665826 1260041465 1180659188 590074436 301564006 "
        "324841922 714752380 1967212989 290476911 815113546 815183409 "
        "1989370850 1182975807 870784323 171062356 1711897606 2024645183 "
        "1333203966 314683764 1785282634 603713754 1904315050 1874254109 "
        "1298675767 1967311508 1946285744 753588304 1847558969 1457540010 "
        "528986741 97857407 1864449494 1868752281 1171249392 1353422942 "
        "832597170 457192338 335135800 1925268166 1845956613 296546482 "
        "1894661934";
    unsigned as[] = {3, 5, 7};
    std::seed_seq sseq(as, as+3);
    std::knuth_b e1(sseq);
    std::ostringstream os;
    os << e1;
    assert(os.str() == a);
}

int main(int, char**)
{
    test1();

  return 0;
}
