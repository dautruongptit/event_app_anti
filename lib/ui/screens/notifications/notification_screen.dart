import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/notification_provider.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/nino/connection_error_dialog.dart';
import '../../../core/network/api_exceptions.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndNotifyOnError();
      context.read<NotificationProvider>().loadUnreadCount();
    });
    _scrollController.addListener(_onScroll);
  }

  /// Tải danh sách thông báo, và nếu lỗi (backend sập, mất mạng...) báo
  /// ngay cho người dùng — trước đây lỗi bị nuốt im lặng, màn chỉ hiện rỗng
  /// trông như "chưa có thông báo" dù thực chất không gọi được API. Lỗi
  /// mất mạng/timeout dùng popup (có nút "Thử lại"), lỗi khác dùng toast.
  Future<void> _loadAndNotifyOnError() async {
    final provider = context.read<NotificationProvider>();
    await provider.loadNotifications(refresh: true);
    if (!mounted) return;
    final error = provider.error;
    if (error == null) return;
    if (isNetworkErrorMessage(error)) {
      showConnectionErrorDialog(context, onRetry: _loadAndNotifyOnError);
    } else {
      showNinoToast(context, error);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<NotificationProvider>();
      if (!provider.isLoading && provider.hasMore) provider.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final neutralSoft = isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text('Thông báo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(onPressed: () => provider.markAllAsRead(), child: Text('Đọc hết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mint))),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadAndNotifyOnError();
          await provider.loadUnreadCount();
        },
        child: _buildBody(provider, txt, mut, fnt, pri, priSoft, neutralSoft),
      ),
    );
  }

  Widget _buildBody(NotificationProvider provider, Color txt, Color mut, Color fnt, Color pri, Color priSoft, Color neutralSoft) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.notifications.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 90),
        children: [
          Center(
            child: Column(
              children: [
                Container(width: 104, height: 104, decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(34)), alignment: Alignment.center, child: Icon(Icons.notifications_none_rounded, size: 42, color: pri)),
                const SizedBox(height: 20),
                Text('Chưa có thông báo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text('Khi có sinh nhật, ngày giỗ hay hoá đơn tới hạn, NINO sẽ nhắc bạn ở đây.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: mut, height: 1.55)),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: provider.notifications.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.notifications.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        final n = provider.notifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Opacity(
            opacity: n.isRead ? 0.68 : 1,
            child: CardRow(
              borderColor: n.isRead ? null : priSoft,
              onTap: () {
                if (!n.isRead) context.read<NotificationProvider>().markAsRead(n.id);
              },
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: n.isRead ? neutralSoft : priSoft, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Icon(n.isRead ? Icons.notifications_rounded : Icons.notifications_active_rounded, color: n.isRead ? mut : pri, size: 18),
              ),
              title: n.title,
              meta: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.body, style: TextStyle(fontSize: 12, color: mut, height: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(AppDateUtils.timeAgo(n.sentAt), style: TextStyle(fontSize: 11, color: fnt)),
                  ],
                ),
              ),
              trailing: !n.isRead ? Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)) : null,
            ),
          ),
        );
      },
    );
  }
}
