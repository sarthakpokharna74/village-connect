import '../models/notice_model.dart';

abstract class NoticeRepository {
  Future<List<NoticeItem>> getNotices();
}

class MockNoticeRepository implements NoticeRepository {
  const MockNoticeRepository();

  @override
  Future<List<NoticeItem>> getNotices() async {
    // Return mock notices immediately. We can simulate delay or fetch from Supabase later.
    return NoticeItem.mockNotices;
  }
}
