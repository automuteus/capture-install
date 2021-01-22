using System.ComponentModel;
using System.Runtime.CompilerServices;
using Capture_Installer_WPF.Annotations;
using MahApps.Metro.Controls.Dialogs;

namespace Capture_Installer_WPF
{
    public class UserDataContext : INotifyPropertyChanged
    {
        public IDialogCoordinator DialogCoordinator { get; set; }
        
        public UserDataContext(IDialogCoordinator dialogCoordinator)
        {
            DialogCoordinator = dialogCoordinator;
            
        }


        public event PropertyChangedEventHandler PropertyChanged;

        [NotifyPropertyChangedInvocator]
        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}