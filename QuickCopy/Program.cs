using System;
using System.Threading;
using System.Windows.Forms;

namespace QuickCopy
{
    /// <summary>
    /// Main application entry point
    /// </summary>
    internal static class Program
    {
        private const string MutexName = "QuickCopyVattenfallEdition_SingleInstance";

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // Singleton instance check
            bool createdNew;
            using (Mutex mutex = new Mutex(true, MutexName, out createdNew))
            {
                if (!createdNew)
                {
                    MessageBox.Show("QuickCopy is already running!", "QuickCopy",
                        MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }

                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                Application.Run(new MainForm());
            }
        }
    }
}
