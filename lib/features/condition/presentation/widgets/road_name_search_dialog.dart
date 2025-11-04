import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/road_name_search_provider.dart';

class RoadNameSearchDialog extends ConsumerStatefulWidget {
  const RoadNameSearchDialog({super.key});

  @override
  ConsumerState<RoadNameSearchDialog> createState() => _RoadNameSearchDialogState();
}

class _RoadNameSearchDialogState extends ConsumerState<RoadNameSearchDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(roadNameSearchViewModelProvider);
    controller = TextEditingController(text: state.keyword);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roadNameSearchViewModelProvider);
    final viewModel = ref.read(roadNameSearchViewModelProvider.notifier);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 제목/설명/닫기
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.green[700], size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '도로명 검색',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF1BAF5D),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '도로명으로 행선지를 검색하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black38),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 18),
              // 입력창 + 검색 버튼
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: '도로명, 지번, 건물명을 입력하세요',
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFB4C8F7),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFB4C8F7),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1BAF5D),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        viewModel.setKeyword(value);
                      },
                      onFieldSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          viewModel.setKeyword(value);
                          viewModel.search(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BAF5D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: (state.keyword.trim().isEmpty)
                          ? null
                          : () {
                              final value = controller.text;
                              viewModel.setKeyword(value);
                              viewModel.search(value);
                            },
                      icon: const Icon(Icons.search, size: 20),
                      label: const Text('검색'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // 검색 결과 영역
              if (state.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (!state.isLoading && state.results.isNotEmpty) ...[
                Text(
                  '검색 결과 (${state.totalCount}건)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF4B5B7A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.results.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    itemBuilder: (context, idx) {
                      final item = state.results[idx];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Color(0xFF1BAF5D),
                        ),
                        title: Text(
                          item.roadAddr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${item.jibunAddr} ${item.bdNm}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        onTap: () {
                          // 선택 시 처리
                          Navigator.of(context).pop(item);
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 0,
                        ),
                        dense: true,
                        minLeadingWidth: 28,
                      );
                    },
                  ),
                ),
              ],
              if (!state.isLoading && state.results.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
