import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:safe/Screens/home_screen/HomePage.dart';
import 'package:provider/provider.dart';
import 'package:safe/providers/profile_provider.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});
  static const String id = 'intro_screen';

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _completeIntroduction() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('من فضلك اكتب اسمك الأول', textAlign: TextAlign.center),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    try {
      await StorageService.saveUserName(_nameController.text);
      await StorageService.setFirstLaunch(false);

      if (mounted) {
        // Initialize providers before navigation
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.initialize();

        // Navigate and replace all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('حدث خطأ، ممكن تعمل ريستارت للابلكيشن',
                textAlign: TextAlign.center),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 5;
            });
          },
          children: [
            // Welcome page
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.waving_hand_rounded,
                      size: 60,
                      color: Constants.getPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'اهلاً بيك يغالي',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.secondaryFontFamily,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'هناخد لفة في الابلكيشن كدا اعرفكم علي بعض، متعملش سكيب',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: Constants.secondaryFontFamily,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expenses & Income
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 60,
                      color: Constants.getPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'تابع فلوسك بسهولة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.secondaryFontFamily,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildFeatureCard(
                          context,
                          icon: Icons.arrow_circle_down_outlined,
                          title: 'المصروفات',
                          description:
                              'سجل كل مصاريفك اليومية وشوف فلوسك راحت فين',
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          icon: Icons.arrow_circle_up_outlined,
                          title: 'الدخل',
                          description: 'سجل دخلك وتابع زيادة محفظتك',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Profiles Feature
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_outline_rounded,
                      size: 60,
                      color: Constants.getPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'حسابات متعددة في مكان واحد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.secondaryFontFamily,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            Constants.getPrimaryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Constants.getPrimaryColor(context)
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'قدر تعمل حسابات مختلفة لكل حاجة:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.secondaryFontFamily,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'حساب للمصاريف الشخصية • \n'
                            'حساب للمشروع بتاعك • \n'
                            'حساب للعيلة • \n'
                            'وأي حاجة تانية تحتاجها •',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: Constants.secondaryFontFamily,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Goals Feature
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      size: 60,
                      color: Constants.getPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'حط اهدافك وحققها',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.secondaryFontFamily,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            Constants.getPrimaryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Constants.getPrimaryColor(context)
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'اهداف مالية زي:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.secondaryFontFamily,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'توفير لحاجة معينة • \n'
                            'تجميع راس مال • \n'
                            'ادخار للطوارئ • \n'
                            'او اي هدف او التزام تاني',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: Constants.secondaryFontFamily,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Name Input Page
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Constants.getPrimaryColor(context)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 60,
                          color: Constants.getPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'اسمك ايه ينجم؟',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.secondaryFontFamily,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ده الاسم اللي هتستخدمة لملف المصاريف الاساسي بتاعك ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: Constants.secondaryFontFamily,
                          height: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'اكتب اسمك هنا',
                          hintStyle: TextStyle(
                              color: Constants.getPrimaryColor(context)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Constants.getPrimaryColor(context),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Constants.getPrimaryColor(context),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'من فضلك اكتب اسمك';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Let's Start Page
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      size: 60,
                      color: Constants.getPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'يلا نبدأ!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.secondaryFontFamily,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'كل حاجة جاهزة.. يلا نبدأ نظبط فلوسك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: Constants.secondaryFontFamily,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('رجوع'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.getPrimaryColor(context),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _completeIntroduction,
                    child: const Text(
                      'يلا نبدأ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _controller.jumpToPage(5),
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        color: Constants.getPrimaryColor(context),
                      ),
                    ),
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: 6,
                      effect: WormEffect(
                        spacing: 16,
                        dotColor: Colors.black12,
                        activeDotColor: Constants.getPrimaryColor(context),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'التالي',
                      style: TextStyle(
                        color: Constants.getPrimaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            icon,
            color: color,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.secondaryFontFamily,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: Constants.secondaryFontFamily,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
