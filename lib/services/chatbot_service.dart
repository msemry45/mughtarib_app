import 'dart:math';

class ChatbotService {
  static final List<String> greetings = [
    'مرحباً! كيف يمكنني مساعدتك اليوم؟',
    'أهلاً وسهلاً! كيف يمكنني خدمتك؟',
    'مرحباً بك! كيف يمكنني مساعدتك؟',
  ];

  static final Map<String, List<String>> responses = {
    'housing': [
      'يمكنني مساعدتك في العثور على سكن طلابي مناسب. هل تفضل سكن قريب من الجامعة؟',
      'لدينا عدة خيارات للسكن الطلابي. هل تريد معرفة المزيد عن أي منها؟',
      'يمكنني إرشادك إلى أفضل خيارات السكن الطلابي في المنطقة.',
    ],
    'host_family': [
      'هل تبحث عن أسرة مضيفة؟ يمكنني مساعدتك في العثور على أسرة مناسبة.',
      'لدينا قائمة من الأسر المضيفة الموثوقة. هل تريد معرفة المزيد؟',
      'يمكنني إخبارك عن شروط الإقامة مع الأسر المضيفة.',
    ],
    'real_estate': [
      'هل تبحث عن مكتب عقاري موثوق؟ يمكنني إرشادك إلى أفضل المكاتب.',
      'لدينا شراكات مع عدة مكاتب عقارية. هل تريد معرفة المزيد؟',
      'يمكنني مساعدتك في العثور على مكتب عقاري يلبي احتياجاتك.',
    ],
    'pricing': [
      'تختلف الأسعار حسب الموقع والخدمات. هل لديك ميزانية محددة؟',
      'يمكنني إخبارك عن متوسط الأسعار في المنطقة التي تبحث عنها.',
      'هل تريد معرفة الأسعار لسكن طلابي أم إقامة مع أسرة مضيفة؟',
    ],
    'location': [
      'يمكنني مساعدتك في العثور على سكن في المنطقة التي تريدها.',
      'هل لديك منطقة محددة في ذهنك؟',
      'يمكنني إخبارك عن أفضل المناطق للطلاب.',
    ],
    'default': [
      'عذراً، لم أفهم سؤالك. هل يمكنك إعادة صياغته؟',
      'هل يمكنك توضيح سؤالك أكثر؟',
      'أنا هنا لمساعدتك في العثور على سكن مناسب. هل لديك سؤال محدد؟',
    ],
  };

  static final Map<String, List<String>> keywords = {
    'housing': ['سكن', 'سكن طلابي', 'شقة', 'غرفة', 'سكن جامعي'],
    'host_family': ['أسرة', 'أسرة مضيفة', 'إقامة مع أسرة', 'عائلة'],
    'real_estate': ['مكتب عقاري', 'عقار', 'مكاتب عقارية', 'وكيل عقاري'],
    'pricing': ['سعر', 'تكلفة', 'ثمن', 'أسعار', 'كم يكلف'],
    'location': ['موقع', 'منطقة', 'مكان', 'أين', 'أقرب'],
  };

  String getGreeting() {
    final random = Random();
    return greetings[random.nextInt(greetings.length)];
  }

  String getResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    for (final entry in keywords.entries) {
      if (entry.value.any((keyword) => lowerMessage.contains(keyword))) {
        final random = Random();
        return responses[entry.key]![random.nextInt(responses[entry.key]!.length)];
      }
    }
    
    final random = Random();
    return responses['default']![random.nextInt(responses['default']!.length)];
  }
} 