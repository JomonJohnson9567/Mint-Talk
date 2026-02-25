import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_cubit.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_item.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_search_filter.dart';

class CallLogContents extends StatelessWidget {
  const CallLogContents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CallLogSearchFilter(),
        Expanded(
          child: BlocBuilder<CallLogCubit, CallLogState>(
            builder: (context, state) {
              if (state is CallLogLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount:
                      state.callLogs.length + 1, // +1 for SizedBox at end
                  itemBuilder: (context, index) {
                    if (index == state.callLogs.length) {
                      return SizedBox(height: 100.h);
                    }
                    final log = state.callLogs[index];
                    return CallLogItem(
                      name: log.name,
                      imageUrl: log.imageUrl,
                      time: log.time,
                      type: log.type,
                      isVideoCall: log.isVideoCall,
                      duration: log.duration,
                      onTap: () {},
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}
