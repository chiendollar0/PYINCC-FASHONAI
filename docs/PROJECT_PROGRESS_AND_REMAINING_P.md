# PYINCC FashionAI — tiến độ Android và backlog P1

Ngày cập nhật: 2026-11-03  
Nhánh làm việc: `fashionai/gracy-20261023`  
Nhánh iOS: `ios` (giữ riêng, tạm dừng)  
Phạm vi: Android UI/P1; **không build APK trong giai đoạn này**.

## 1. Quy tắc build đã áp dụng

- Workflow: `.github/workflows/android-apk.yml`.
- Push lên nhánh Android chạy asset gate, Flutter analyze và widget tests.
- Job APK có điều kiện: chỉ chạy từ `workflow_dispatch` khi người vận hành bật rõ `build_apk=true`.
- Mặc định workflow dispatch không build APK.
- Không dùng build CI hoặc widget test để tuyên bố đã nghiệm thu trên điện thoại.

Commit khóa build: `3362d343248f7f8aa3b34e7bcaf3d75e5b5b633b`.

## 2. Các thay đổi P1 đã ghi vào mã nguồn

### Home
- Thêm lối tắt có nhãn trực tiếp tới Studio, Store, Tủ đồ và Account.
- Giữ bốn tab chính Home / Studio / Store / Account.

### Studio tool menu
- Tập trung metadata công cụ trong `StudioTool.all`: stable key, label, accessibility label, icon và action.
- Selected state dùng stable key thay vì so sánh chuỗi nhãn.
- Menu gọi action theo enum; bổ sung tooltip và semantics label.

### Trạng thái tính năng trung thực
- Face Swap 3D được khóa và ghi rõ chưa khả dụng vì chưa có engine đã kiểm chứng.
- Skin Care controls bị khóa cho đến khi có hiệu ứng vật liệu GLB thực sự; không cho phép UI giả lập thao tác đã áp dụng lên avatar.
- Store hiển thị trạng thái catalog chưa kết nối; không đưa ra danh sách sàn/giá/liên kết như thể đã tích hợp.
- Big Bag nêu rõ chưa có trang phục 3D để thử.

### Kiểm thử bổ sung
- Home shortcuts và điều hướng.
- Accessibility labels của bốn công cụ Studio.
- Skin Care disabled-state.
- Face Swap disabled-state.
- Compact viewport 320×640 và kiểm tra Flutter exception.

Các commit mã nguồn liên quan:
- `285bb7fec76314c56d434c6bc229dff65dc0a72c` — trạng thái tính năng trung thực.
- `0f13011cc97d1ea9bd23e7c8e9b9a61482b18a18` — test cho disabled-state và viewport nhỏ.
- `80e2b155c9d3c686c8620a7f82ec04e5553624a0` — Home shortcuts và Studio tool registry.
- `5485272a4b6b3ac60496e8eaa51accdf378169ad` — test Home và menu accessibility.
- `391c430d1f7e14e4c0c3768d25330e181c8b21dd` — hoàn tất migration tool registry, loại bỏ tham chiếu state cũ.

## 3. Bằng chứng CI và giới hạn

- Workflow #115 trên commit cũ `c741bd8f2a8110d69bbe32aed72ef150eaffe784` đã thành công; build debug APK ở thời điểm đó đã chạy. Đây là bằng chứng lịch sử, không phải bản APK của các thay đổi P1 mới.
- Các run #117–#121 phát hiện lỗi test/analyze trong các commit trung gian; đã truy nguyên các nguyên nhân: test còn kỳ vọng empty-state cũ, tham chiếu state `_panel` chưa đổi hết, constructor test chưa cập nhật và finder `Studio` bị trùng sau khi thêm Home shortcut.
- Run #122 trên commit `391c430d1f7e14e4c0c3768d25330e181c8b21dd`: static analysis PASS, widget tests FAIL do finder `find.text('Studio')` khớp đồng thời Home shortcut và bottom tab. Đã sửa helper để chọn đúng `NavigationDestination` trong commit `736c729cea7f39cd18afa3a037c5236560d48fad`.
- Run #124 trên commit test-fix `736c729cea7f39cd18afa3a037c5236560d48fad` đang xác minh lại. Run #123 dùng test helper cũ nên không phải kết quả nghiệm thu cuối. Chưa ghi PASS cho đến khi run #124 hoàn tất.
- Asset gate thành công ở các run đã kiểm tra; điều này không xác nhận hình ảnh hiển thị đúng trên thiết bị.
- Build job bị skip trên push theo thiết kế. Không tạo APK mới trong giai đoạn sửa P1.

## 4. P1 còn cần nghiệm thu

| Hạng mục | Trạng thái |
|---|---|
| Home có lối tắt tới 4 khu vực | Đã cập nhật mã; chờ CI xác nhận |
| Registry icon/action/accessibility của Studio | Đã cập nhật mã; chờ CI xác nhận |
| Empty state và trạng thái tính năng không gây hiểu nhầm | Đã cập nhật mã; chờ CI xác nhận |
| Đánh giá hierarchy, spacing và panel trên màn hình Android thực | Chưa nghiệm thu |
| Ảnh chụp Home/Studio trên thiết bị thật | Chưa có bằng chứng mới |
| Tương tác 3D thực tế, độ ổn định WebView và hiệu năng | Chưa nghiệm thu |

## 5. Các giới hạn sản phẩm không được đánh dấu hoàn thành

- Face Swap 3D chưa có engine đã kiểm chứng.
- Skin Care chưa được nối với material/texture của GLB.
- Store chưa có catalog và liên kết sản phẩm đã xác minh.
- Tủ đồ/Big Bag chưa có pipeline lưu trang phục và garment 3D.
- GLB Gracy Lee hiện tại chỉ là asset kỹ thuật tạm thời; chưa phải model PYINCC cuối cùng.
- Production authentication, dữ liệu/persistence và kiểm thử thiết bị cần các đợt riêng.

## 6. Điều kiện chuyển sang giai đoạn APK/UAT

Chỉ khi:
1. CI trên commit cuối cùng đạt gate-tests, asset-gate, static analysis và widget tests.
2. P1 Home/Studio được kiểm tra trên kích thước màn hình Android mục tiêu; không có overflow, che khuất hoặc lỗi điều hướng.
3. Chủ dự án cho phép chuyển sang giai đoạn build APK.

Sau đó mới chạy workflow thủ công với `build_apk=true`, kiểm tra APK package/signature/asset hash và cài lên thiết bị để ghi nhận ảnh chụp, tương tác, render 3D, hiệu năng và lỗi thực tế.

## 7. Branch cleanup

Mục tiêu giữ Android và iOS làm hai nhánh làm việc. Các nhánh cũ và PR chưa xử lý cần được đối chiếu ancestry/PR trước khi xóa. Không xóa nhánh mặc định `main` trước khi chuyển default branch và xác nhận không còn phụ thuộc. Việc xóa refs chưa được thực hiện trong lần cập nhật này.
