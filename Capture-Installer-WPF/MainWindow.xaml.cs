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
            var result = await this.ShowMessageAsync("INFO", "You are installing Among Us Capture, and dotnet 5. Do you want to continue?", MessageDialogStyle.AffirmativeAndNegative);
            if (result == MessageDialogResult.Negative)
            {
                App.Current.Shutdown(24);
            }
            //User agreed to continue installation
        }
    }
}
