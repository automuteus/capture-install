using ControlzEx.Theming;
using MahApps.Metro.Controls;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using MahApps.Metro.Controls.Dialogs;
using System.IO;
using System.Net;
using Humanizer;

namespace Capture_Installer_WPF
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : MetroWindow
    {
        private UserDataContext context;
        public MainWindow()
        {
            context = new UserDataContext(DialogCoordinator.Instance);
            this.DataContext = context;
            InitializeComponent();
            ThemeManager.Current.ThemeSyncMode = ThemeSyncMode.SyncAll;
            ThemeManager.Current.SyncTheme();

        }

        private async void MainWindow_OnLoaded(object sender, RoutedEventArgs e)
        {
            var result = await this.ShowMessageAsync("INFO", "You are installing Among Us Capture, and dotnet 5. Do you want to continue?", MessageDialogStyle.AffirmativeAndNegative, 
                new MetroDialogSettings{  DefaultButtonFocus=MessageDialogResult.Affirmative, AffirmativeButtonText="Yes", NegativeButtonText="Exit" });
            if (result == MessageDialogResult.Negative)
            {
                App.Current.Shutdown(24);
            }
            //User agreed to continue installation
            await Task.Factory.StartNew(Install, TaskCreationOptions.LongRunning);

        }

        private async void Install()
        {
            string strCmdText;
            strCmdText = "/c dotnet --list-runtimes > \"%TEMP%\\desktopRuntimes.txt\"";
            var cmd = System.Diagnostics.Process.Start("CMD.exe", strCmdText);
            string[] lines;
            cmd.WaitForExit();
            try
            {
                lines = System.IO.File.ReadAllLines(System.IO.Path.Combine(System.IO.Path.GetTempPath(), "desktopRuntimes.txt"));
                if (!lines.Any(x => x.StartsWith("Microsoft.WindowsDesktop.App 5.0.1", StringComparison.InvariantCultureIgnoreCase)))
                {
                    InstallDotnet(); //Need to install dotnet
                }
                else
                {
                    Console.WriteLine("do not need to install dotnet");
                }
            }
            catch (Exception e)
            {
                InstallDotnet(); //Need to install dotnet
            }
        }

        private async void InstallDotnet()
        {
            string DownloadURL = "https://download.visualstudio.microsoft.com/download/pr/c6a74d6b-576c-4ab0-bf55-d46d45610730/f70d2252c9f452c2eb679b8041846466/windowsdesktop-runtime-5.0.1-win-x64.exe";
            var DownloadProgress =
                        await context.DialogCoordinator.ShowProgressAsync(context, "Downloading Dotnet", "Percent: 0% (0/0)", isCancelable: false);
            DownloadProgress.Maximum = 100;
            using (var client = new WebClient())
            {
                var downloadPath = System.IO.Path.GetTempFileName();
                client.DownloadProgressChanged += (sender, args) =>
                {
                    DownloadProgress.SetProgress(args.ProgressPercentage);
                    DownloadProgress.SetMessage($"Percent: {args.ProgressPercentage}% ({args.BytesReceived.Bytes().Humanize("#.##")}/{args.TotalBytesToReceive.Bytes().Humanize("#.##")})");
                };
                client.DownloadFileCompleted += async (sender, args) =>
                {
                    if (!(args.Error is null))
                    {
                        await DownloadProgress.CloseAsync();
                        var errorBox = await context.DialogCoordinator.ShowMessageAsync(context, "ERROR",
                            args.Error.Message, MessageDialogStyle.AffirmativeAndNegative,
                            new MetroDialogSettings
                            {
                                AffirmativeButtonText = "retry",
                                NegativeButtonText = "cancel",
                                DefaultButtonFocus = MessageDialogResult.Affirmative
                            });
                        if (errorBox == MessageDialogResult.Affirmative)
                        {
                            await Task.Factory.StartNew(InstallDotnet, TaskCreationOptions.LongRunning);
                        }
                    }
                    else
                    {
                        System.Diagnostics.Process.Start(downloadPath);
                        await DownloadProgress.CloseAsync();
                        await context.DialogCoordinator.ShowMessageAsync(context, "Please install dotnet", "Dotnet is required for the next version of AutoMuteUs.", MessageDialogStyle.Affirmative);
                    }
                };
                var downloaderClient = client.DownloadFileTaskAsync(DownloadURL, downloadPath);
            }
        }
    }
}
