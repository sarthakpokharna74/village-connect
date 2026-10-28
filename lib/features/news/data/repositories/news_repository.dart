import 'package:flutter/foundation.dart';
import '../../../../core/localization/translations.dart';
import '../models/news_article_model.dart';

/// Interface for accessing and managing village news and updates in GramConnect.
abstract class NewsRepository {
  /// Fetch all published news articles with optional category filter, search query, and sorting.
  Future<List<NewsArticle>> getArticles({
    String? category,
    String? query,
    bool newestFirst = true,
  });

  /// Fetch the current featured story (must be published).
  Future<NewsArticle?> getFeaturedArticle();

  /// Fetch a single article by its unique ID.
  Future<NewsArticle?> getArticleById(String id);

  /// Fetch all bookmarked articles given a list of IDs.
  Future<List<NewsArticle>> getSavedArticles(List<String> bookmarkedIds);

  /// Submit a community news suggestion (marked as pendingReview).
  Future<bool> submitNewsSuggestion(NewsSuggestion suggestion);

  /// Report incorrect information on an article.
  Future<bool> reportArticleIssue(NewsReport report);
}

/// Mock/Local implementation of NewsRepository for Dhawalpuri.
/// Preloaded with verified local news articles across key categories.
class MockNewsRepository implements NewsRepository {
  static final MockNewsRepository _instance = MockNewsRepository._internal();
  factory MockNewsRepository() => _instance;
  MockNewsRepository._internal();

  final List<NewsSuggestion> _submittedSuggestions = [];
  final List<NewsReport> _submittedReports = [];

  List<NewsArticle> _buildMockArticles() {
    final now = DateTime.now();

    String t(String lang, String key, String fallback) {
      return AppTranslations.values[lang]?[key] ?? fallback;
    }

    return [
      // Article 1: Village Development (Featured)
      NewsArticle(
        id: 'news_solar_water_pumps',
        headline: t('en', 'news1_headline', 'Solar Powered Water Pumping Project Approved for Dhawalpuri Wadis'),
        localizedHeadlines: {
          'en': t('en', 'news1_headline', 'Solar Powered Water Pumping Project Approved for Dhawalpuri Wadis'),
          'mr': t('mr', 'news1_headline', 'ढवळपुरीतील वाड्यांसाठी सौर ऊर्जा पाणी उपसा प्रकल्प मंजूर'),
          'hi': t('hi', 'news1_headline', 'ढवळपुरी की विभिन्न वाडियों के लिए सौर ऊर्जा जल पम्पिंग परियोजना स्वीकृत'),
        },
        summary: t('en', 'news1_summary', 'Parner taluka administration clears installation of 3 dedicated solar pump sets to ensure regular drinking water.'),
        localizedSummaries: {
          'en': t('en', 'news1_summary', 'Parner taluka administration clears installation of 3 dedicated solar pump sets to ensure regular drinking water.'),
          'mr': t('mr', 'news1_summary', 'पारनेर तालुका प्रशासनाकडून ढवळपुरीतील उंचावरील वाड्यांमध्ये सुरळीत पिण्याच्या पाण्यासाठी ३ सौर पंप बसवण्यास मंजुरी.'),
          'hi': t('hi', 'news1_summary', 'पारनेर तालुका प्रशासन द्वारा ढवळपुरी की ऊंचाई वाली वाडियों में नियमित पेयजल आपूर्ति के लिए ३ सोलर पंप सेट लगाने की मंजूरी।'),
        },
        body: t('en', 'news1_body', 'Under the rural renewable energy and drinking water infrastructure initiative...'),
        localizedBodies: {
          'en': t('en', 'news1_body', 'Under the rural renewable energy and drinking water infrastructure initiative, a dedicated solar water lift scheme for Dhawalpuri has been formally sanctioned by the Parner Panchayat Samiti and Dhawalpuri Gram Panchayat.\n\nThis will permanently resolve water supply issues in elevated pockets such as Maruti Galli, Malwadi, and Khandoba Vasti during peak summer months. The project includes three 5-horsepower solar submersible pumps connected to the existing storage reservoir.\n\nGram Panchayat officials confirmed that work is scheduled to commence next month following technical clearance from MSEDCL and the Water Supply Department. This green energy initiative will reduce the village\'s pumping electricity expenditure by nearly 40 percent.'),
          'mr': t('mr', 'news1_body', 'ग्रामीण अपारंपरिक ऊर्जा आणि पिण्याच्या पाण्याच्या पायाभूत सुविधा उपक्रमांतर्गत, पारनेर पंचायत समिती आणि ढवळपुरी ग्रामपंचायतीच्या संयुक्त प्रयत्नांतून सौर जलउपसा योजनेला अधिकृत मंजुरी मिळाली आहे.\n\nया प्रकल्पामुळे मारुती गल्ली, माळवाडी आणि खंडोबा वस्ती या उंचावरील भागांतील उन्हाळ्यातील पाणीटंचाईवर कायमस्वरूपी मात करता येईल. या योजनेत विद्यमान साठवण तलावाशी जोडलेले तीन ५-अश्वशक्तीचे सौर सबमर्सिबल पंप बसवले जातील.\n\nमहावितरण व पाणीपुरवठा विभागाच्या तांत्रिक तपासणीनंतर पुढील महिन्यात प्रत्यक्ष कामाला सुरुवात होणार असल्याचे ग्रामपंचायत प्रशासनाने सांगितले. या हरित प्रकल्पामुळे गावाच्या वीजबिलात सुमारे ४० टक्के बचत होणार आहे.'),
          'hi': t('hi', 'news1_body', 'ग्रामीण नवीकरणीय ऊर्जा और पेयजल अधोसंरचना पहल के तहत, पारनेर पंचायत समिति और ढवळपुरी ग्राम पंचायत के प्रयासों से समर्पित सौर जल उत्थान योजना को मंजूरी मिली है।\n\nमारुति गली, मालवाड़ी और खंडोबा बस्ती जैसे ऊंचाई वाले क्षेत्रों में गर्मी के दिनों में आने वाली पानी की समस्या का इससे स्थायी समाधान होगा। इस परियोजना में मौजूदा जलाशय से जुड़े तीन ५-हॉर्सपावर के सोलर सबमर्सिबल पंप लगाए जाएंगे।\n\nग्राम पंचायत अधिकारियों ने पुष्टि की कि महावितरण और जलापूर्ति विभाग के तकनीकी निरीक्षण के बाद अगले महीने काम शुरू होगा। इससे गाँव के पम्पिंग बिजली बिल में लगभग ४० प्रतिशत की कमी आएगी।'),
        },
        category: 'village_development',
        authorName: t('en', 'news1_author', 'Kishore Gholap (Rural Dev Correspondent)'),
        localizedAuthors: {
          'en': t('en', 'news1_author', 'Kishore Gholap (Rural Dev Correspondent)'),
          'mr': t('mr', 'news1_author', 'किशोर घोलप (ग्रामविकास बातमीदार)'),
          'hi': t('hi', 'news1_author', 'किशोर घोलप (ग्राम विकास संवाददाता)'),
        },
        publisherName: t('en', 'news1_publisher', 'Dhawalpuri Gram Samachar'),
        localizedPublishers: {
          'en': t('en', 'news1_publisher', 'Dhawalpuri Gram Samachar'),
          'mr': t('mr', 'news1_publisher', 'ढवळपुरी ग्राम बातमीपत्र'),
          'hi': t('hi', 'news1_publisher', 'ढवळपुरी ग्राम समाचार'),
        },
        sourceUrl: 'https://ahilyanagar.gov.in',
        publishedAt: now.subtract(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 14)),
        occurrenceDate: now.subtract(const Duration(days: 2)),
        publicationStatus: NewsPublicationStatus.published,
        verificationStatus: NewsVerificationStatus.verified,
        isFeatured: true,
        tags: const ['WaterSupply', 'SolarEnergy', 'Dhawalpuri', 'Infrastructure'],
        relatedPlaceIds: const ['kalu_dam_area', 'gram_panchayat_office'],
      ),

      // Article 2: Agriculture & Farming
      NewsArticle(
        id: 'news_organic_fertilizer_distribution',
        headline: t('en', 'news2_headline', 'Organic Fertilizer and Seed Distribution Drive at Dhawalpuri Sub-Centre'),
        localizedHeadlines: {
          'en': t('en', 'news2_headline', 'Organic Fertilizer and Seed Distribution Drive at Dhawalpuri Sub-Centre'),
          'mr': t('mr', 'news2_headline', 'खरीप हंगामासाठी ढवळपुरी उपकेंद्रात सेंद्रिय खते व बियाणे वाटप मोहीम'),
          'hi': t('hi', 'news2_headline', 'खरीफ सीजन के लिए ढवळपुरी उप-केंद्र पर जैविक खाद व बीज वितरण'),
        },
        summary: t('en', 'news2_summary', 'Over 150 local farmers receive subsidized organic bio-fertilizers and soil health cards from Taluka Agriculture Dept.'),
        localizedSummaries: {
          'en': t('en', 'news2_summary', 'Over 150 local farmers receive subsidized organic bio-fertilizers and soil health cards from Taluka Agriculture Dept.'),
          'mr': t('mr', 'news2_summary', 'तालुका कृषी विभागामार्फत ढवळपुरीतील १५० हून अधिक शेतकऱ्यांना अनुदानित दरात सेंद्रिय खते व मृद आरोग्य पत्रिका वाटप.'),
          'hi': t('hi', 'news2_summary', 'तालुका कृषि विभाग द्वारा ढवळपुरी के १५० से अधिक किसानों को रियायती दरों पर जैविक खाद एवं मृदा स्वास्थ्य कार्ड वितरित।'),
        },
        body: t('en', 'news2_body', 'A two-day distribution camp was conducted at the Dhawalpuri Agriculture Sub-Centre...'),
        localizedBodies: {
          'en': t('en', 'news2_body', 'A two-day distribution camp was conducted at the Dhawalpuri Agriculture Sub-Centre under the joint auspices of the Parner Agriculture Department and Dhawalpuri Shetkari Bachat Gat.\n\nSubsidized bio-fertilizers including Trichoderma and Rhizobium culture suited for bajra, soybean, and onion cultivation were distributed to more than 150 farmers. Agronomy specialists conducted live demonstrations on composting and soil conditioning techniques.\n\nFarmers were encouraged to register on the MahaDBT portal for drip-irrigation subsidies and PM-KUSUM solar agricultural pump schemes available for the upcoming season.'),
          'mr': t('mr', 'news2_body', 'पारनेर कृषी विभाग आणि ढवळपुरी शेतकरी बचत गटाच्या संयुक्त विद्यमाने गावातील कृषी उपकेंद्रावर दोन दिवसीय वाटप शिबिर पार पडले.\n\nबाजरी, सोयाबीन आणि कांदा पिकांसाठी उपयुक्त ट्रायकोडर्मा, रायझोबियम यांसारखी सेंद्रिय जैव खते १५० हून अधिक शेतकऱ्यांना सवलतीच्या दरात देण्यात आली. कृषी अधिकाऱ्यांनी सेंद्रिय कंपोस्ट खत निर्मितीचे प्रात्यक्षिक दाखवले.\n\nआगामी हंगामात सूक्ष्म ठिबक सिंचन अनुदान आणि सौर कृषी पंपांचा लाभ घेण्यासाठी शेतकऱ्यांनी महाडीबीटी पोर्टलवर नोंदणी करण्याचे आवाहन करण्यात आले आहे.'),
          'hi': t('hi', 'news2_body', 'पारनेर कृषि विभाग और ढवळपुरी शेतकरी बचत गट के संयुक्त तत्वावधान में गाँव के कृषि उप-केंद्र पर दो दिवसीय वितरण शिविर संपन्न हुआ।\n\nशिविर में बाजरा व प्याज की फसलों के लिए उपयोगी ट्राइकोडर्मा, राइजोबियम जैसी जैव उर्वरक रियायती दरों पर दिए गए। साथ ही १५० से अधिक किसानों को मृदा स्वास्थ्य कार्ड बांटे गए। कृषि अधिकारियों ने जैविक खाद बनाने का व्यावहारिक प्रदर्शन भी किया।\n\nकिसानों से आगामी सीजन में ड्रिप सिंचाई सब्सिडी का लाभ लेने के लिए महाडीबीटी पोर्टल पर पंजीकरण कराने का अनुरोध किया गया।'),
        },
        category: 'agriculture_farming',
        authorName: t('en', 'news2_author', 'Santosh Gawade (Agri Assistant)'),
        localizedAuthors: {
          'en': t('en', 'news2_author', 'Santosh Gawade (Agri Assistant)'),
          'mr': t('mr', 'news2_author', 'संतोष गावडे (कृषी सहाय्यक)'),
          'hi': t('hi', 'news2_author', 'संतोष गावडे (कृषि सहायक)'),
        },
        publisherName: t('en', 'news2_publisher', 'Krishi Varta Parner'),
        localizedPublishers: {
          'en': t('en', 'news2_publisher', 'Krishi Varta Parner'),
          'mr': t('mr', 'news2_publisher', 'कृषी वार्ता पारनेर'),
          'hi': t('hi', 'news2_publisher', 'कृषि वार्ता पारनेर'),
        },
        sourceUrl: 'https://krishi.maharashtra.gov.in',
        publishedAt: now.subtract(const Duration(days: 3, hours: 4)),
        updatedAt: null,
        occurrenceDate: now.subtract(const Duration(days: 4)),
        publicationStatus: NewsPublicationStatus.published,
        verificationStatus: NewsVerificationStatus.verified,
        isFeatured: false,
        tags: const ['Agriculture', 'OrganicFarming', 'Dhawalpuri', 'Kharif'],
        relatedPlaceIds: const ['village_market_kendra'],
      ),

      // Article 3: Education & Youth
      NewsArticle(
        id: 'news_zp_school_science_award',
        headline: t('en', 'news3_headline', 'ZP Primary School Dhawalpuri Students Win Taluka Science Exhibition'),
        localizedHeadlines: {
          'en': t('en', 'news3_headline', 'ZP Primary School Dhawalpuri Students Win Taluka Science Exhibition'),
          'mr': t('mr', 'news3_headline', 'जिल्हा परिषद प्राथमिक शाळा ढवळपुरीच्या विद्यार्थ्यांनी जिंकले तालुका विज्ञान प्रदर्शन'),
          'hi': t('hi', 'news3_headline', 'जिला परिषद प्राथमिक विद्यालय ढवळपुरी के छात्रों ने तालुका विज्ञान प्रतियोगिता जीती'),
        },
        summary: t('en', 'news3_summary', 'Class 7 students secure 1st prize in Parner taluka science fair with automated soil moisture sensor drip model.'),
        localizedSummaries: {
          'en': t('en', 'news3_summary', 'Class 7 students secure 1st prize in Parner taluka science fair with automated soil moisture sensor drip model.'),
          'mr': t('mr', 'news3_summary', 'पारनेर तालुका विज्ञान प्रदर्शनात स्वयंचलित ठिबक सिंचन मॉडेल सादर करणाऱ्या ढवळपुरी शाळेच्या सातवीच्या विद्यार्थ्यांनी मिळवला प्रथम क्रमांक.'),
          'hi': t('hi', 'news3_summary', 'ड्रिप सिंचाई मॉडल प्रस्तुत करने वाले ढवळपुरी स्कूल के कक्षा ७ के छात्रों ने पारनेर तालुका विज्ञान प्रदर्शनी में प्रथम स्थान प्राप्त किया।'),
        },
        body: t('en', 'news3_body', 'Students of Zilla Parishad Primary School Dhawalpuri made the village proud...'),
        localizedBodies: {
          'en': t('en', 'news3_body', 'Students of Zilla Parishad Primary School Dhawalpuri brought laurels to the village by winning the first prize at the Parner Taluka Rural Science Exhibition.\n\nGuided by science mentor Shri Darekar, Class 7 students Aarav Thube and Sneha Shinde designed an affordable automated soil-moisture sensor that activates drip watering only when root moisture drops below critical levels.\n\nThe innovative prototype has now been nominated for the upcoming District Science Fair at Ahilyanagar. The School Management Committee and Gram Panchayat congratulated the young innovators and announced a scholarship grant.'),
          'mr': t('mr', 'news3_body', 'पारनेर येथे आयोजित तालुकास्तरीय ग्रामीण विज्ञान प्रदर्शनात जिल्हा परिषद प्राथमिक शाळा ढवळपुरीच्या विद्यार्थ्यांनी प्रथम क्रमांक पटकावून गावाचा गौरव वाढवला.\n\nविज्ञान शिक्षक श्री. दरेकर यांच्या मार्गदर्शनाखाली इयत्ता सातवीतील विद्यार्थी आरव ठुबे व स्नेहा शिंदे यांनी मातीतील आर्द्रता मोजून स्वयंचलितपणे ठिबक सिंचन सुरू करणारे उपकरण तयार केले.\n\nया प्रकल्पाची पुढील महिन्यात अहिल्यानगर येथे होणाऱ्या जिल्हा विज्ञान प्रदर्शनासाठी निवड झाली आहे. शाळा व्यवस्थापन समिती आणि ग्रामपंचायतीने विद्यार्थ्यांचे कौतुक करून शैक्षणिक प्रोत्साहन निधी जाहीर केला.'),
          'hi': t('hi', 'news3_body', 'पारनेर में आयोजित तालुकास्तरीय ग्रामीण विज्ञान एवं नवाचार प्रदर्शनी में जिला परिषद प्राथमिक विद्यालय ढवळपुरी के छात्रों ने प्रथम स्थान प्राप्त कर गाँव का मान बढ़ाया।\n\nविज्ञान शिक्षक श्री दरेकर के मार्गदर्शन में कक्षा ७ के छात्र आरव ठुबे और स्नेहा शिंदे ने स्वचालित नमी संवेदक (सॉइल मॉइस्चर सेंसर) आधारित ड्रिप सिंचाई प्रणाली का कार्यशील मॉडल प्रस्तुत किया।\n\nइस परियोजना को अगले महीने अहिल्यानगर में होने वाली जिला विज्ञान प्रदर्शनी के लिए चुना गया है। स्कूल प्रबंधन समिति और ग्राम पंचायत ने छात्रों को बधाई दी और शैक्षणिक प्रोत्साहन अनुदान की घोषणा की।'),
        },
        category: 'education',
        authorName: t('en', 'news3_author', 'Sunita Shinde (Education Reporter)'),
        localizedAuthors: {
          'en': t('en', 'news3_author', 'Sunita Shinde (Education Reporter)'),
          'mr': t('mr', 'news3_author', 'सुनिता शिंदे (शिक्षण बातमीदार)'),
          'hi': t('hi', 'news3_author', 'सुनीता शिंदे (शिक्षा संवाददाता)'),
        },
        publisherName: t('en', 'news3_publisher', 'Dhawalpuri Shikshan Samvad'),
        localizedPublishers: {
          'en': t('en', 'news3_publisher', 'Dhawalpuri Shikshan Samvad'),
          'mr': t('mr', 'news3_publisher', 'ढवळपुरी शिक्षण संवाद'),
          'hi': t('hi', 'news3_publisher', 'ढवळपुरी शिक्षण संवाद'),
        },
        sourceUrl: 'https://ahilyanagarzp.gov.in',
        publishedAt: now.subtract(const Duration(days: 5, hours: 1)),
        updatedAt: null,
        occurrenceDate: now.subtract(const Duration(days: 6)),
        publicationStatus: NewsPublicationStatus.published,
        verificationStatus: NewsVerificationStatus.verified,
        isFeatured: false,
        tags: const ['Education', 'ZPSchool', 'ScienceFair', 'Youth'],
        relatedPlaceIds: const ['zp_primary_school'],
      ),

      // Article 4: Gram Panchayat Updates
      NewsArticle(
        id: 'news_gram_sabha_plastic_ban',
        headline: t('en', 'news4_headline', 'Special Gram Sabha Passes Resolution for Clean & Plastic-Free Dhawalpuri'),
        localizedHeadlines: {
          'en': t('en', 'news4_headline', 'Special Gram Sabha Passes Resolution for Clean & Plastic-Free Dhawalpuri'),
          'mr': t('mr', 'news4_headline', 'ग्रामसभेत स्वच्छ व प्लास्टिकमुक्त ढवळपुरीसाठी एकमुखाने ठराव मंजूर'),
          'hi': t('hi', 'news4_headline', 'ग्रामसभा में स्वच्छ एवं प्लास्टिक मुक्त ढवळपुरी का सर्वसम्मत प्रस्ताव पारित'),
        },
        summary: t('en', 'news4_summary', 'Chaired by the Sarpanch, meeting resolves to phase out single-use plastic bags and enforce waste segregation across all wards.'),
        localizedSummaries: {
          'en': t('en', 'news4_summary', 'Chaired by the Sarpanch, meeting resolves to phase out single-use plastic bags and enforce waste segregation across all wards.'),
          'mr': t('mr', 'news4_summary', 'सरपंचांच्या अध्यक्षतेखाली पार पडलेल्या विशेष ग्रामसभेत एकल-वापर प्लास्टिक पिशव्यांवर बंदी व कचरा वर्गीकरणाचा निर्णय.'),
          'hi': t('hi', 'news4_summary', 'सरपंच की अध्यक्षता में आयोजित विशेष ग्रामसभा में एकल-उपयोग प्लास्टिक पर प्रतिबंध और कचरा पृथक्करण का निर्णय।'),
        },
        body: t('en', 'news4_body', 'A special Gram Sabha convened at the Dhawalpuri Gram Panchayat hall...'),
        localizedBodies: {
          'en': t('en', 'news4_body', 'A special Gram Sabha was held at the Dhawalpuri Gram Panchayat hall with enthusiastic participation from village elders, youth groups, and women\'s Self-Help Groups (SHGs).\n\nThe assembly unanimously resolved to completely phase out single-use plastic bags starting next month. Local grocers and weekly market vendors will transition to reusable cloth bags made by village women\'s cooperatives.\n\nSarpanch Ramesh Thube urged all residents to cooperate in keeping village roads, temple surrounds, and drainage channels clean to make Dhawalpuri a model clean village in Parner taluka.'),
          'mr': t('mr', 'news4_body', 'ढवळपुरी ग्रामपंचायत कार्यालयात सरपंचांच्या अध्यक्षतेखाली ग्रामस्थ, युवक मंडळे आणि महिला बचत गटांच्या उपस्थितीत विशेष ग्रामसभा पार पडली.\n\nया सभेमध्ये पुढील महिन्यापासून ढवळपुरी गाव शंभर टक्के एकल-वापर प्लास्टिकमुक्त करण्याचा ठराव सर्वानुमते मंजूर करण्यात आला. गावातील सर्व दुकानदारांना कापडी पिशव्या वापरण्याचे आवाहन करण्यात आले आहे.\n\nसरपंच रमेश ठुबे यांनी गावातील रस्ते, मंदिर परिसर व सांडपाणी नाले स्वच्छ ठेवण्यासाठी सर्वांनी सक्रिय सहकार्य करण्याचे आवाहन केले.'),
          'hi': t('hi', 'news4_body', 'ढवळपुरी ग्राम पंचायत भवन में सरपंच की अध्यक्षता में ग्रामीणों, युवा मंडलों और महिला स्वयं सहायता समूहों की उपस्थिति में विशेष ग्रामसभा का आयोजन किया गया।\n\nसभा में सर्वसम्मति से अगले माह से ढवळपुरी को एकल-उपयोग प्लास्टिक से मुक्त करने का प्रस्ताव पारित किया गया। गाँव की सभी दुकानों में कपड़े के थैलों का उपयोग करने की अपील की गई है और मुख्य बस्तियों व साप्ताहिक बाजार के लिए अलग-अलग कचरा संग्रहण प्रणाली शुरू की जाएगी।\n\nसरपंच रमेश ठुबे ने सभी दुकानदारों, प्याज व्यापारियों और ग्रामीणों से ढवळपुरी को पारनेर तालुका का एक आदर्श हरा-भरा गाँव बनाने में सहयोग करने का आग्रह किया।'),
        },
        category: 'gram_panchayat_updates',
        authorName: t('en', 'news4_author', 'Gram Panchayat Media Cell'),
        localizedAuthors: {
          'en': t('en', 'news4_author', 'Gram Panchayat Media Cell'),
          'mr': t('mr', 'news4_author', 'ग्रामपंचायत प्रसिद्धी कक्ष'),
          'hi': t('hi', 'news4_author', 'ग्राम पंचायत मीडिया सेल'),
        },
        publisherName: t('en', 'news4_publisher', 'Dhawalpuri Panchayat Records'),
        localizedPublishers: {
          'en': t('en', 'news4_publisher', 'Dhawalpuri Panchayat Records'),
          'mr': t('mr', 'news4_publisher', 'ढवळपुरी पंचायत दफ्तर'),
          'hi': t('hi', 'news4_publisher', 'ढवळपुरी पंचायत रिकॉर्ड'),
        },
        sourceUrl: 'https://rdd.maharashtra.gov.in',
        publishedAt: now.subtract(const Duration(days: 7, hours: 3)),
        updatedAt: null,
        occurrenceDate: now.subtract(const Duration(days: 8)),
        publicationStatus: NewsPublicationStatus.published,
        verificationStatus: NewsVerificationStatus.verified,
        isFeatured: false,
        tags: const ['GramPanchayat', 'CleanVillage', 'GramSabha', 'Environment'],
        relatedPlaceIds: const ['gram_panchayat_office'],
      ),

      // Article 5: Health & Public Awareness
      NewsArticle(
        id: 'news_phc_health_eye_camp',
        headline: t('en', 'news5_headline', 'Free Eye Screening & Health Camp Held at Dhawalpuri Primary Health Centre'),
        localizedHeadlines: {
          'en': t('en', 'news5_headline', 'Free Eye Screening & Health Camp Held at Dhawalpuri Primary Health Centre'),
          'mr': t('mr', 'news5_headline', 'ढवळपुरी प्राथमिक आरोग्य केंद्रात मोफत नेत्रतपासणी व आरोग्य शिबिर'),
          'hi': t('hi', 'news5_headline', 'ढवळपुरी प्राथमिक स्वास्थ्य केंद्र पर निःशुल्क नेत्र जांच एवं स्वास्थ्य शिविर'),
        },
        summary: t('en', 'news5_summary', 'Over 220 villagers screened; free prescription spectacles and medical consultations provided to senior citizens.'),
        localizedSummaries: {
          'en': t('en', 'news5_summary', 'Over 220 villagers screened; free prescription spectacles and medical consultations provided to senior citizens.'),
          'mr': t('mr', 'news5_summary', '२२० हून अधिक ग्रामस्थांची मोफत आरोग्य तपासणी; ज्येष्ठ नागरिकांना चष्मे व औषधोपचार वाटप.'),
          'hi': t('hi', 'news5_summary', '२२० से अधिक ग्रामीणों की निःशुल्क स्वास्थ्य जांच; वरिष्ठ नागरिकों को मुफ्त चश्मे व दवाओं का वितरण किया गया।'),
        },
        body: t('en', 'news5_body', 'A comprehensive free health checkup and vision screening camp was organized...'),
        localizedBodies: {
          'en': t('en', 'news5_body', 'A comprehensive free health checkup and vision screening camp was organized at the Dhawalpuri Primary Health Centre in collaboration with the District Hospital, Ahilyanagar and Parner Rural Hospital.\n\nOver 220 residents underwent diagnostic checkups for blood pressure, diabetes, vision acuity, and cardiac indicators. Thirty-eight senior citizens identified with cataracts were registered for free sponsored surgical procedures at Ahilyanagar with village transport arranged.\n\nMedical Officer Dr. Kulkarni announced that specialized follow-up clinics will operate every first Thursday at the Dhawalpuri PHC.'),
          'mr': t('mr', 'news5_body', 'अहिल्यानगर जिल्हा रुग्णालय आणि पारनेर ग्रामीण रुग्णालयाच्या सहकार्याने ढवळपुरी प्राथमिक आरोग्य केंद्रात व्यापक मोफत आरोग्य तपासणी शिबिर संपन्न झाले.\n\nशिबिरामध्ये २२६ ग्रामस्थांची रक्तदाब, मधुमेह, ईसीजी व डोळ्यांची तपासणी करण्यात आली. मोतीबिंदू आढळलेल्या ३८ ज्येष्ठ नागरिकांना मोफत शस्त्रक्रियेसाठी नोंदवून घेण्यात आले असून त्यांच्या प्रवासाची व्यवस्था समिती करणार आहे.\n\nवैद्यकीय अधिकारी डॉ. कुलकर्णी यांनी सांगितले की दर महिन्याच्या पहिल्या गुरुवारी ढवळपुरी आरोग्य केंद्रात विशेष पाठपुरावा ओपीडी सुरू राहील.'),
          'hi': t('hi', 'news5_body', 'अहिल्यानगर जिला अस्पताल और पारनेर ग्रामीण अस्पताल के सहयोग से ढवळपुरी प्राथमिक स्वास्थ्य केंद्र पर व्यापक निःशुल्क स्वास्थ्य जांच शिविर आयोजित हुआ।\n\nशिविर में २२६ ग्रामीणों की रक्तचाप, मधुमेह, ईसीजी और आँखों की जांच की गई। मोतियाबिंद से पीड़ित ३८ वरिष्ठ नागरिकों को निःशुल्क सर्जरी के लिए पंजीकृत किया गया, जिसके लिए वाहन की व्यवस्था समिति द्वारा की जाएगी।\n\nचिकित्सा अधिकारी डॉ. कुलकर्णी ने बताया कि हर महीने के पहले गुरुवार को ढवळपुरी पीएचसी में विशेष फॉलो-अप ओपीडी जारी रहेगी।'),
        },
        category: 'health_awareness',
        authorName: t('en', 'news5_author', 'Dr. S. Kulkarni (Medical Officer)'),
        localizedAuthors: {
          'en': t('en', 'news5_author', 'Dr. S. Kulkarni (Medical Officer)'),
          'mr': t('mr', 'news5_author', 'डॉ. एस. कुलकर्णी (वैद्यकीय अधिकारी)'),
          'hi': t('hi', 'news5_author', 'डॉ. एस. कुलकर्णी (चिकित्सा अधिकारी)'),
        },
        publisherName: t('en', 'news5_publisher', 'Parner Arogya Patrika'),
        localizedPublishers: {
          'en': t('en', 'news5_publisher', 'Parner Arogya Patrika'),
          'mr': t('mr', 'news5_publisher', 'पारनेर आरोग्य पत्रिका'),
          'hi': t('hi', 'news5_publisher', 'पारनेर आरोग्य पत्रिका'),
        },
        sourceUrl: 'https://arogya.maharashtra.gov.in',
        publishedAt: now.subtract(const Duration(days: 10, hours: 5)),
        updatedAt: null,
        occurrenceDate: now.subtract(const Duration(days: 11)),
        publicationStatus: NewsPublicationStatus.published,
        verificationStatus: NewsVerificationStatus.verified,
        isFeatured: false,
        tags: const ['Healthcare', 'PHC', 'FreeCamp', 'PublicHealth'],
        relatedPlaceIds: const ['primary_health_centre'],
      ),

      // Article 6: Culture & Heritage
      NewsArticle(
        id: 'news_temple_inscriptions_documentation',
        headline: t('en', 'news6_headline', 'Ancient Temple Architecture & Stone Inscriptions Documented in Dhawalpuri'),
        localizedHeadlines: {
          'en': t('en', 'news6_headline', 'Ancient Temple Architecture & Stone Inscriptions Documented in Dhawalpuri'),
          'mr': t('mr', 'news6_headline', 'ढवळपुरीतील पुरातन मंदिर वास्तुकला व शिलालेखांचे दस्तऐवजीकरण पूर्ण'),
          'hi': t('hi', 'news6_headline', 'ढवळपुरी में प्राचीन मंदिर स्थापत्य एवं शिलालेखों का दस्तावेजीकरण पूर्ण'),
        },
        summary: t('en', 'news6_summary', 'Local heritage researchers record intricate medieval carvings, stepwells, and hero stones to preserve village history.'),
        localizedSummaries: {
          'en': t('en', 'news6_summary', 'Local heritage researchers record intricate medieval carvings, stepwells, and hero stones to preserve village history.'),
          'mr': t('mr', 'news6_summary', 'गावाचा ऐतिहासिक वारसा जपण्यासाठी जुन्या मंदिर परिसरातील पाषाण शिल्पे, बारव व वीरगळांचे छायाचित्रण व नोंदणी.'),
          'hi': t('hi', 'news6_summary', 'गाँव की ऐतिहासिक धरोहर को सहेजने के लिए पुराने मंदिर परिसर की पाषाण कला और बावड़ियों का दस्तावेजीकरण।'),
        },
        body: t('en', 'news6_body', 'A dedicated team of historians and regional researchers visited Dhawalpuri...'),
        localizedBodies: {
          'en': t('en', 'news6_body', 'A team of cultural historians and regional researchers completed a photographic and epigraphic survey of medieval stone carvings and stepwells in Dhawalpuri.\n\nVillage elders shared oral traditions associated with the historic stone temple precinct and historic hero stones (Veergals) that mark the courage of historical village guardians.\n\nA comprehensive dossier is being prepared to submit to the State Archaeology Department to recognize Dhawalpuri\'s heritage structures and promote responsible rural heritage trails.'),
          'mr': t('mr', 'news6_body', 'इतिहास अभ्यासक आणि संशोधकांच्या पथकाने ढवळपुरीला भेट देऊन मध्ययुगीन दगडी कोरीव काम, वीरगळ आणि बारवांचा सखोल अभ्यास व छायांकन केले.\n\nगावातील जाणकारांनी पुरातन मंदिरांचे महत्त्व आणि पारंपरिक लोककथांची सविस्तर माहिती संशोधकांना दिली.\n\nढवळपुरीचा हा समृद्ध सांस्कृतिक वारसा जतन करण्यासाठी आणि ग्रामीण पर्यटनाला चालना देण्यासाठी राज्य पुरातत्व विभागाकडे प्रस्ताव पाठवण्याची तयारी सुरू आहे.'),
          'hi': t('hi', 'news6_body', 'इतिहासकारों और शोधकर्ताओं के एक दल ने ढवळपुरी का दौरा कर मध्यकालीन पाषाण नक्काशी, वीरगलों और प्राचीन सीढ़ीदार कुओं (बावड़ियों) का अध्ययन व छायांकन किया।\n\nगाँव के बुजुर्गों ने शोधकर्ताओं को प्राचीन मंदिरों के ऐतिहासिक महत्व और मौखिक लोक परंपराओं की विस्तृत जानकारी दी।\n\nढवळपुरी की इस सांस्कृतिक धरोहर को संरक्षित करने और ग्रामीण पर्यटन को बढ़ावा देने के लिए महाराष्ट्र पुरातत्व धरोहर रजिस्टर में दर्ज करने हेतु रिपोर्ट तैयार की जा रही है।'),
        },
        category: 'culture_heritage',
        authorName: t('en', 'news6_author', 'Prof. V. Deshmukh (Historian)'),
        localizedAuthors: {
          'en': t('en', 'news6_author', 'Prof. V. Deshmukh (Historian)'),
          'mr': t('mr', 'news6_author', 'प्रा. व्ही. देशमुख (इतिहास अभ्यासक)'),
          'hi': t('hi', 'news6_author', 'प्रो. वी. देशमुख (इतिहासकार)'),
        },
        publisherName: t('en', 'news6_publisher', 'Maharashtra Heritage Forum'),
        localizedPublishers: {
          'en': t('en', 'news6_publisher', 'Maharashtra Heritage Forum'),
          'mr': t('mr', 'news6_publisher', 'महाराष्ट्र हेरिटेज फोरम'),
          'hi': t('hi', 'news6_publisher', 'महाराष्ट्र हेरिटेज फोरम'),
        },
        sourceUrl: 'https://cultural.maharashtra.gov.in',
        publishedAt: now.subtract(const Duration(days: 14, hours: 6)),
        updatedAt: null,
        occurrenceDate: now.subtract(const Duration(days: 16)),
        publicationStatus: NewsPublicationStatus.published,
        verificationStatus: NewsVerificationStatus.verified,
        isFeatured: false,
        tags: const ['Heritage', 'History', 'Temples', 'Culture'],
        relatedPlaceIds: const ['durgadevi_temple'],
      ),
    ];
  }

  @override
  Future<List<NewsArticle>> getArticles({
    String? category,
    String? query,
    bool newestFirst = true,
  }) async {
    // Simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 50));

    // Only published articles are shown in public feed
    var list = _buildMockArticles()
        .where((a) => a.publicationStatus == NewsPublicationStatus.published)
        .toList();

    // Category filter
    if (category != null && category.trim().isNotEmpty && category != 'all') {
      list = list.where((a) => a.category == category).toList();
    }

    // Search query filter (across headline, summary, body, category, author, publisher)
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((a) {
        final hl = a.headline.toLowerCase();
        final sm = a.summary.toLowerCase();
        final bd = a.body.toLowerCase();
        final au = a.authorName.toLowerCase();
        final pb = a.publisherName.toLowerCase();
        final cat = a.category.toLowerCase();
        final tagsMatch = a.tags.any((t) => t.toLowerCase().contains(q));

        // Check localized fields
        bool localizedMatch = false;
        if (a.localizedHeadlines != null) {
          localizedMatch = localizedMatch || a.localizedHeadlines!.values.any((v) => v.toLowerCase().contains(q));
        }
        if (a.localizedSummaries != null) {
          localizedMatch = localizedMatch || a.localizedSummaries!.values.any((v) => v.toLowerCase().contains(q));
        }
        if (a.localizedBodies != null) {
          localizedMatch = localizedMatch || a.localizedBodies!.values.any((v) => v.toLowerCase().contains(q));
        }

        return hl.contains(q) ||
            sm.contains(q) ||
            bd.contains(q) ||
            au.contains(q) ||
            pb.contains(q) ||
            cat.contains(q) ||
            tagsMatch ||
            localizedMatch;
      }).toList();
    }

    // Sorting
    list.sort((a, b) {
      if (newestFirst) {
        return b.publishedAt.compareTo(a.publishedAt);
      } else {
        return a.publishedAt.compareTo(b.publishedAt);
      }
    });

    return list;
  }

  @override
  Future<NewsArticle?> getFeaturedArticle() async {
    await Future.delayed(const Duration(milliseconds: 30));
    final articles = _buildMockArticles();
    try {
      return articles.firstWhere(
        (a) => a.isFeatured && a.publicationStatus == NewsPublicationStatus.published,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<NewsArticle?> getArticleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 30));
    final articles = _buildMockArticles();
    try {
      return articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<NewsArticle>> getSavedArticles(List<String> bookmarkedIds) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final articles = _buildMockArticles();
    return articles
        .where((a) => bookmarkedIds.contains(a.id) && a.publicationStatus == NewsPublicationStatus.published)
        .toList();
  }

  @override
  Future<bool> submitNewsSuggestion(NewsSuggestion suggestion) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _submittedSuggestions.add(suggestion);
    debugPrint('News suggestion submitted: ${suggestion.headline} (Status: ${suggestion.status.name})');
    return true;
  }

  @override
  Future<bool> reportArticleIssue(NewsReport report) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _submittedReports.add(report);
    debugPrint('Article issue reported for ${report.articleId}: ${report.issueType}');
    return true;
  }

  /// Helper for testing
  List<NewsSuggestion> get submittedSuggestions => List.unmodifiable(_submittedSuggestions);
  List<NewsReport> get submittedReports => List.unmodifiable(_submittedReports);
}
