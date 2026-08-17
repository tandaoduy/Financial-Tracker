# Money Manager

Ứng dụng quản lý thu chi cá nhân được xây dựng bằng Flutter. Money Manager giúp ghi lại giao dịch, theo dõi số dư theo tháng và quan sát cơ cấu chi tiêu ngay trên thiết bị, không cần kết nối mạng.

<p align="center">
  <a href="https://flutter.dev/" title="Flutter">
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/flutter/flutter-original.svg" alt="Flutter" width="64" height="64" />
  </a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://dart.dev/" title="Dart">
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/dart/dart-original.svg" alt="Dart" width="64" height="64" />
  </a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://sqlite.org/" title="SQLite">
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/sqlite/sqlite-original.svg" alt="SQLite" width="64" height="64" />
  </a>
</p>

## Tính năng

- Thêm, chỉnh sửa và xóa giao dịch thu/chi.
- Ghi nhận tên giao dịch, số tiền, danh mục, ghi chú và ngày giao dịch.
- Phân loại giao dịch bằng các danh mục có sẵn cho thu nhập và chi tiêu.
- Dashboard tổng hợp số dư, tổng thu và tổng chi trong tháng hiện tại.
- Biểu đồ tròn thể hiện chi tiêu theo danh mục.
- Hiển thị tỷ lệ chi tiêu trên thu nhập và danh mục chi nhiều nhất.
- Danh sách giao dịch gần đây và màn hình lịch sử đầy đủ.
- Tự động cập nhật giao diện khi dữ liệu thay đổi.
- Lưu dữ liệu cục bộ bằng SQLite; ứng dụng hoạt động offline.

## Công nghệ sử dụng

- [Flutter](https://flutter.dev/) và Dart
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) để quản lý trạng thái
- [Drift](https://drift.simonbinder.eu/) và SQLite để lưu trữ cục bộ
- [go_router](https://pub.dev/packages/go_router) để điều hướng
- [fl_chart](https://pub.dev/packages/fl_chart) để hiển thị biểu đồ
- `intl` để định dạng ngày tháng và tiền tệ Việt Nam
- `uuid` để tạo mã định danh giao dịch

### Flutter và Dart

Flutter là UI toolkit chính của ứng dụng, cho phép dùng chung một codebase Dart cho Android và iOS. Trong Money Manager, Flutter đảm nhiệm:

- Xây dựng giao diện theo Material 3 với `MaterialApp.router`, widget và theme dùng chung.
- Điều hướng giữa dashboard và form giao dịch bằng `go_router`.
- Cập nhật từng phần giao diện theo state từ BLoC thay vì thao tác trực tiếp lên widget.
- Hiển thị dashboard, animation, danh sách giao dịch và biểu đồ bằng `fl_chart`.
- Định dạng ngày và tiền Việt Nam thông qua package `intl`.

Dart cung cấp type safety, `async`/`await` và Stream. Stream đặc biệt quan trọng trong dự án: khi SQLite thay đổi, Drift phát dữ liệu mới, BLoC tạo state mới và Flutter tự dựng lại phần giao diện liên quan.

### SQLite và Drift

[SQLite](https://sqlite.org/) là cơ sở dữ liệu quan hệ nhúng chạy ngay trong ứng dụng. Dữ liệu không cần máy chủ riêng và vẫn sử dụng được khi thiết bị không có mạng. Dự án truy cập SQLite thông qua Drift để có truy vấn type-safe và stream dữ liệu reactive.

Các thành phần lưu trữ chính:

- `Transactions` định nghĩa bảng và các cột của giao dịch.
- `AppDatabase` khai báo database, schema version và kết nối SQLite.
- `DriftTransactionLocalDataSource` thực hiện truy vấn đọc, thêm, sửa và xóa.
- `TransactionMapper` chuyển đổi giữa bản ghi database và entity của Domain.
- `TransactionRepositoryImpl` che giấu chi tiết Drift khỏi các layer phía trên.

Bảng `transactions` sử dụng `id` làm khóa chính và có index trên `transactionDate` để hỗ trợ việc sắp xếp giao dịch theo thời gian. Truy vấn danh sách trả về `Stream<List<TransactionRow>>`, do đó Drift sẽ phát lại kết quả khi dữ liệu liên quan thay đổi.

```text
Flutter Widget
      ↑ State
TransactionBloc
      ↑ Stream<List<TransactionEntity>>
Repository + Mapper
      ↑ Stream<List<TransactionRow>>
Drift
      ↑ SQL
SQLite (money_manager.sqlite)
```

SQLite hiện chỉ lưu dữ liệu trên thiết bị. Kiến trúc Repository giúp ứng dụng có thể bổ sung API, đồng bộ đám mây hoặc cơ chế sao lưu sau này mà không buộc UI phải biết dữ liệu đến từ đâu.

## Yêu cầu môi trường

- Flutter SDK tương thích với Dart `^3.12.2`
- Android Studio hoặc Xcode (tùy nền tảng chạy)
- Android emulator, iOS Simulator hoặc thiết bị thật

Kiểm tra môi trường Flutter trước khi chạy:

```bash
flutter doctor
```

## Cài đặt và chạy dự án

1. Clone repository và đi vào thư mục dự án:

   ```bash
   git clone <repository-url>
   cd MoneyManager
   ```

2. Cài đặt dependencies:

   ```bash
   flutter pub get
   ```

3. Chạy ứng dụng:

   ```bash
   flutter run
   ```

Để chọn thiết bị cụ thể, xem danh sách thiết bị bằng `flutter devices`, sau đó chạy:

```bash
flutter run -d <device-id>
```

## Kiểm tra chất lượng

Chạy phân tích tĩnh:

```bash
flutter analyze
```

Chạy test:

```bash
flutter test
```

Các widget test hiện tại tập trung vào form giao dịch, gồm hiển thị danh mục, kiểm tra dữ liệu bắt buộc và gửi dữ liệu hợp lệ.

## Sinh mã

Drift sử dụng code generation cho lớp database. Khi thay đổi bảng, database hoặc các model sinh mã, chạy:

```bash
dart run build_runner build --delete-conflicting-outputs
```

File `lib/core/database/app_database.g.dart` được sinh tự động và không nên chỉnh sửa thủ công.

## Kiến trúc

Dự án sử dụng **Feature-first Architecture kết hợp Clean Architecture**. Mã nguồn được nhóm theo từng tính năng nghiệp vụ; bên trong mỗi tính năng tiếp tục chia thành ba layer `presentation`, `domain` và `data`.

### Các layer chính

- **Presentation:** chứa Page, Widget và BLoC. Layer này hiển thị dữ liệu, nhận thao tác của người dùng và gửi event đến `TransactionBloc`.
- **Domain:** chứa Entity, Repository contract và Use case. Đây là phần mô tả quy tắc nghiệp vụ, không phụ thuộc Flutter, Drift hoặc cách dữ liệu được lưu trữ.
- **Data:** chứa Data source, Mapper và Repository implementation. Layer này triển khai repository của Domain và giao tiếp trực tiếp với Drift/SQLite.
- **Core:** chứa thành phần dùng chung toàn ứng dụng như database và router.
- **Injection:** khởi tạo database, repository, use case và BLoC, sau đó kết nối các dependency với nhau.

Kiến trúc tuân theo **Dependency Rule**: layer bên ngoài phụ thuộc vào layer bên trong. `Presentation` gọi các Use case trong `Domain`, còn `Data` triển khai interface Repository do `Domain` định nghĩa. Nhờ đó, logic nghiệp vụ không phụ thuộc trực tiếp vào giao diện hoặc SQLite.

### Cấu trúc thư mục

```text
lib/
├── app/                         # MaterialApp, theme và BLoC cấp ứng dụng
├── core/
│   ├── database/                # Cấu hình Drift/SQLite
│   └── router/                  # Khai báo route bằng go_router
├── features/
│   └── transactions/
│       ├── data/                # Data source, mapper, repository implementation
│       ├── domain/              # Entity, repository contract và use case
│       └── presentation/        # BLoC, page và widget
├── injection/                   # Khởi tạo và kết nối dependencies
└── main.dart                    # Entry point
```

### Luồng dữ liệu

Khi người dùng thêm, sửa hoặc xóa giao dịch:

```text
UI → Event → TransactionBloc → Use case → Repository → Data source → SQLite
```

Khi dữ liệu trong database thay đổi, luồng cập nhật đi theo chiều ngược lại:

```text
SQLite → Drift Stream → Repository → TransactionBloc → State → UI
```

`TransactionBloc` đăng ký stream giao dịch từ Drift, vì vậy danh sách, dashboard và biểu đồ tự động cập nhật sau mỗi thao tác mà không cần tải lại thủ công.

### Quản lý trạng thái

Ứng dụng dùng mô hình **BLoC (Business Logic Component)**:

- `TransactionEvent` mô tả hành động hoặc sự kiện xảy ra.
- `TransactionBloc` xử lý event, gọi use case và theo dõi stream dữ liệu.
- `TransactionState` chứa trạng thái tải dữ liệu, danh sách giao dịch, trạng thái thao tác và thông báo lỗi.
- Widget sử dụng `BlocProvider` và `BlocConsumer` để nhận state và cập nhật giao diện.

### Lợi ích của kiến trúc

- Tách giao diện, nghiệp vụ và nguồn dữ liệu thành các phần độc lập.
- Dễ kiểm thử use case và BLoC mà không cần giao diện thật.
- Có thể thay Drift bằng nguồn dữ liệu khác mà ít ảnh hưởng đến Domain và Presentation.
- Dễ mở rộng thêm các feature như ngân sách, mục tiêu tiết kiệm hoặc báo cáo.

## Dữ liệu cục bộ

Database có schema version `1` và được lưu trong thư mục documents của ứng dụng với tên `money_manager.sqlite`. Mỗi giao dịch gồm:

- ID
- Tên và số tiền
- Loại giao dịch (`income` hoặc `expense`)
- Danh mục và ghi chú tùy chọn
- Ngày giao dịch
- Thời điểm tạo và cập nhật

Dữ liệu chỉ nằm trên thiết bị hiện tại. Xóa dữ liệu ứng dụng hoặc gỡ cài đặt có thể làm mất các giao dịch đã lưu.

## Build bản phát hành

Android:

```bash
flutter build apk --release
```

iOS (yêu cầu macOS và Xcode):

```bash
flutter build ios --release
```

## Trạng thái dự án

Phiên bản hiện tại: `1.0.0+1`. Dự án đang tập trung vào quản lý giao dịch offline trên Android và iOS; chưa có đăng nhập, đồng bộ đám mây hoặc sao lưu dữ liệu.
