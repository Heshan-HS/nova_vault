#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  RECT work_area;
  ::SystemParametersInfo(SPI_GETWORKAREA, 0, &work_area, 0);
  int work_width = work_area.right - work_area.left;
  int work_height = work_area.bottom - work_area.top;

  int window_width = 1320;
  int window_height = 820;

  if (window_width > work_width) {
    window_width = work_width - 20;
  }
  if (window_height > work_height) {
    window_height = work_height - 20;
  }

  int x = work_area.left + (work_width - window_width) / 2;
  int y = work_area.top + (work_height - window_height) / 2;
  if (x < 10) x = 10;
  if (y < 10) y = 10;

  FlutterWindow window(project);
  Win32Window::Point origin(x, y);
  Win32Window::Size size(window_width, window_height);
  if (!window.Create(L"NovaVault", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
