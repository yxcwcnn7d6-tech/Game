using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QuickCopy
{
    /// <summary>
    /// Main application form for QuickCopy Vattenfall Edition
    /// </summary>
    public partial class MainForm : Form
    {
        #region Constants - Vattenfall Color Scheme
        private static readonly Color COLOR_VATTENFALL_BLUE = Color.FromArgb(0x20, 0x71, 0xB5);
        private static readonly Color COLOR_VATTENFALL_YELLOW = Color.FromArgb(0xFF, 0xDA, 0x00);
        private static readonly Color COLOR_VATTENFALL_GREY = Color.FromArgb(0x4E, 0x4B, 0x48);
        private static readonly Color COLOR_PANEL_BG = Color.FromArgb(0xE8, 0xF4, 0xF8);
        #endregion

        #region Private Fields
        private string leftPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
        private string rightPath = "";
        private int sortColumnLeft = -1;
        private bool sortDirectionLeft = true;
        private int sortColumnRight = -1;
        private bool sortDirectionRight = true;
        private bool operationRunning = false;
        private Process? robocopyProcess = null;
        private DateTime operationStartTime;
        private Point dragStart;
        private bool isDragging = false;
        private string fileFilter = "";
        private const string INI_FILE = "QuickCopy.ini";
        #endregion

        #region Constructor
        public MainForm()
        {
            InitializeComponent();
            LoadSettings();
            InitializeUI();
            LoadFolder(listViewLeft, leftPath);
            if (!string.IsNullOrEmpty(rightPath) && Directory.Exists(rightPath))
            {
                LoadFolder(listViewRight, rightPath);
            }
            UpdateStatusBar();
            UpdateGroupHeaders();
        }
        #endregion

        #region Initialization
        private void InitializeUI()
        {
            // Set form properties
            this.FormBorderStyle = FormBorderStyle.None;
            this.BackColor = Color.FromArgb(0xF0, 0xF0, 0xF0);
            this.StartPosition = FormStartPosition.Manual;

            // Apply colors
            panelTitleBar.BackColor = COLOR_VATTENFALL_BLUE;
            lblTitle.ForeColor = COLOR_VATTENFALL_YELLOW;
            btnCopyRight.BackColor = COLOR_VATTENFALL_YELLOW;
            btnCopyRight.ForeColor = COLOR_VATTENFALL_GREY;
            btnMoveRight.BackColor = COLOR_VATTENFALL_BLUE;
            btnMoveRight.ForeColor = Color.White;

            // Set initial states
            btnCancelOperation.Enabled = false;
            LogActivity("Ready.");
        }
        #endregion

        #region Window Dragging
        private void PanelTitleBar_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left && e.X < btnMinimize.Left)
            {
                isDragging = true;
                dragStart = new Point(e.X, e.Y);
            }
        }

        private void PanelTitleBar_MouseMove(object sender, MouseEventArgs e)
        {
            if (isDragging)
            {
                Point newLocation = this.Location;
                newLocation.X += e.X - dragStart.X;
                newLocation.Y += e.Y - dragStart.Y;
                this.Location = newLocation;
            }
        }

        private void PanelTitleBar_MouseUp(object sender, MouseEventArgs e)
        {
            isDragging = false;
        }
        #endregion

        #region Button Event Handlers
        private void BtnClose_Click(object sender, EventArgs e)
        {
            SaveSettings();
            Application.Exit();
        }

        private void BtnMinimize_Click(object sender, EventArgs e)
        {
            this.WindowState = FormWindowState.Minimized;
        }

        private void BtnLeftBrowse_Click(object sender, EventArgs e)
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.SelectedPath = leftPath;
                dialog.Description = "Select source folder";
                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    leftPath = dialog.SelectedPath;
                    LoadFolder(listViewLeft, leftPath);
                    UpdateStatusBar();
                    LogActivity($"Source folder changed to: {leftPath}");
                }
            }
        }

        private void BtnRightBrowse_Click(object sender, EventArgs e)
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.SelectedPath = rightPath;
                dialog.Description = "Select destination folder";
                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    rightPath = dialog.SelectedPath;
                    LoadFolder(listViewRight, rightPath);
                    UpdateStatusBar();
                    LogActivity($"Destination folder changed to: {rightPath}");
                }
            }
        }

        private void BtnLeftUp_Click(object sender, EventArgs e)
        {
            GoUpOneLevel(listViewLeft, ref leftPath);
            UpdateStatusBar();
        }

        private void BtnRightUp_Click(object sender, EventArgs e)
        {
            GoUpOneLevel(listViewRight, ref rightPath);
            UpdateStatusBar();
        }

        private void BtnSwap_Click(object sender, EventArgs e)
        {
            string temp = leftPath;
            leftPath = rightPath;
            rightPath = temp;

            if (string.IsNullOrEmpty(rightPath))
            {
                rightPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
            }

            LoadFolder(listViewLeft, leftPath);
            LoadFolder(listViewRight, rightPath);
            UpdateStatusBar();
            LogActivity("Swapped source and destination folders");
        }

        private void BtnCopyRight_Click(object sender, EventArgs e)
        {
            if (!operationRunning)
            {
                CopySelected(false);
            }
        }

        private void BtnMoveRight_Click(object sender, EventArgs e)
        {
            if (!operationRunning)
            {
                CopySelected(true);
            }
        }

        private void BtnClearActivity_Click(object sender, EventArgs e)
        {
            txtActivity.Clear();
            progressBar.Value = 0;
            LogActivity("Activity log cleared.");
        }

        private void BtnCancelOperation_Click(object sender, EventArgs e)
        {
            if (operationRunning && robocopyProcess != null && !robocopyProcess.HasExited)
            {
                robocopyProcess.Kill();
                LogActivity("Operation cancelled by user");
                progressBar.Value = 0;
                btnCopyRight.Enabled = true;
                btnMoveRight.Enabled = true;
                btnCancelOperation.Enabled = false;
                operationRunning = false;
                robocopyProcess = null;
            }
        }

        private void BtnAbout_Click(object sender, EventArgs e)
        {
            string aboutText = @"QuickCopy Vattenfall Edition
Version 1.0
Author: Marcus Thilander YISPC
Date: 2024-12-22

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
KEYBOARD SHORTCUTS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ctrl+C     Copy selected items
Ctrl+M     Move selected items
Ctrl+A     Select all items
Delete     Delete selected items
Escape     Deselect all items
F5         Refresh both panels

RIGHT-CLICK MENU:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Copy Path             Copy full path
Open in Explorer      Open location
Delete                Move to Recycle Bin
Properties            Show file properties

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
© 2025 YISPC - All rights reserved
Powered by Windows Robocopy";

            MessageBox.Show(aboutText, "About QuickCopy", MessageBoxButtons.OK, MessageBoxIcon.Information);
            LogActivity("Opened About dialog");
        }

        private void BtnApplyFilter_Click(object sender, EventArgs e)
        {
            ApplyFileFilter();
        }
        #endregion

        #region File Operations
        private void LoadFolder(ListView listView, string path)
        {
            listView.Items.Clear();

            if (string.IsNullOrEmpty(path) || !Directory.Exists(path))
            {
                UpdatePathLabel(listView, path);
                return;
            }

            UpdatePathLabel(listView, path);

            try
            {
                // Load directories
                foreach (var dir in Directory.GetDirectories(path))
                {
                    var dirInfo = new DirectoryInfo(dir);
                    var item = new ListViewItem(dirInfo.Name);
                    item.SubItems.Add("<DIR>");
                    item.SubItems.Add("Folder");
                    item.SubItems.Add(dirInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm"));
                    item.Tag = dir;
                    listView.Items.Add(item);
                }

                // Load files
                foreach (var file in Directory.GetFiles(path))
                {
                    var fileInfo = new FileInfo(file);

                    // Apply filter
                    if (!MatchesFilter(fileInfo.Name))
                        continue;

                    var item = new ListViewItem(fileInfo.Name);
                    item.SubItems.Add(FormatBytes(fileInfo.Length));
                    item.SubItems.Add("File");
                    item.SubItems.Add(fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm"));
                    item.Tag = file;
                    listView.Items.Add(item);
                }
            }
            catch (Exception ex)
            {
                LogActivity($"Error loading folder: {ex.Message}");
            }

            UpdateGroupHeaders();
        }

        private void UpdatePathLabel(ListView listView, string path)
        {
            if (listView == listViewLeft)
            {
                lblLeftPath.Text = path;
            }
            else
            {
                lblRightPath.Text = string.IsNullOrEmpty(path) ? "No destination selected" : path;
            }
        }

        private void GoUpOneLevel(ListView listView, ref string currentPath)
        {
            if (string.IsNullOrEmpty(currentPath))
                return;

            var parent = Directory.GetParent(currentPath);
            if (parent != null)
            {
                currentPath = parent.FullName;
                LoadFolder(listView, currentPath);
                LogActivity($"Navigated up to: {currentPath}");
            }
        }

        private void CopySelected(bool moveOperation)
        {
            if (listViewLeft.SelectedItems.Count == 0)
            {
                MessageBox.Show("No items selected!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (string.IsNullOrEmpty(rightPath))
            {
                MessageBox.Show("No destination folder selected!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (moveOperation)
            {
                var result = MessageBox.Show(
                    $"Are you sure you want to MOVE the selected items?\n\n" +
                    $"This will permanently remove them from the source location!\n\n" +
                    $"Selected items: {listViewLeft.SelectedItems.Count}",
                    "Confirm Move",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Warning,
                    MessageBoxDefaultButton.Button2);

                if (result == DialogResult.No)
                {
                    LogActivity("Move operation cancelled by user.");
                    return;
                }
            }

            // Build robocopy command
            string optionsBase = " /R:10 /W:30 /IPG:10";
            if (chkCompress.Checked) optionsBase += " /COMPRESS";
            if (chkNewer.Checked) optionsBase += " /XO";
            string moveFlag = moveOperation ? " /MOVE" : "";
            string operation = moveOperation ? "MOVE" : "COPY";

            // Separate files and directories
            List<string> files = new List<string>();
            List<string> directories = new List<string>();

            foreach (ListViewItem item in listViewLeft.SelectedItems)
            {
                string fullPath = item.Tag?.ToString() ?? "";
                if (string.IsNullOrEmpty(fullPath)) continue;

                if (Directory.Exists(fullPath))
                    directories.Add(fullPath);
                else
                    files.Add(fullPath);
            }

            LogActivity($"Starting {operation} operation: {listViewLeft.SelectedItems.Count} item(s)");
            LogActivity($"From: {leftPath}");
            LogActivity($"To: {rightPath}");
            LogActivity("---");

            progressBar.Value = 0;
            operationStartTime = DateTime.Now;

            // Create temporary batch file to avoid command line length limits
            string tempBatchFile = Path.Combine(Path.GetTempPath(), $"quickcopy_{Guid.NewGuid():N}.bat");
            StringBuilder batchContent = new StringBuilder();
            batchContent.AppendLine("@echo off");
            batchContent.AppendLine("chcp 65001 >nul"); // UTF-8 encoding

            // Copy files individually (using batch file avoids command line length limits)
            foreach (string filePath in files)
            {
                string fileName = Path.GetFileName(filePath);
                batchContent.AppendLine($"robocopy \"{leftPath}\" \"{rightPath}\" \"{fileName}\"{optionsBase}{moveFlag}");
            }

            // Copy directories individually
            foreach (string dirPath in directories)
            {
                string dirName = Path.GetFileName(dirPath);
                batchContent.AppendLine($"robocopy \"{dirPath}\" \"{Path.Combine(rightPath, dirName)}\" /E{optionsBase}{moveFlag}");
            }

            // Write batch file
            File.WriteAllText(tempBatchFile, batchContent.ToString());

            // Start batch file process
            robocopyProcess = new Process();
            robocopyProcess.StartInfo.FileName = tempBatchFile;
            robocopyProcess.StartInfo.UseShellExecute = false;
            robocopyProcess.StartInfo.RedirectStandardOutput = true;
            robocopyProcess.StartInfo.RedirectStandardError = true;
            robocopyProcess.StartInfo.CreateNoWindow = true;
            robocopyProcess.StartInfo.StandardOutputEncoding = System.Text.Encoding.UTF8;
            robocopyProcess.EnableRaisingEvents = true;
            robocopyProcess.OutputDataReceived += RobocopyProcess_OutputDataReceived;
            robocopyProcess.ErrorDataReceived += RobocopyProcess_ErrorDataReceived;
            robocopyProcess.Exited += (s, e) =>
            {
                // Clean up temp batch file
                try { File.Delete(tempBatchFile); } catch { }
                RobocopyProcess_Exited(s, e);
            };

            robocopyProcess.Start();
            robocopyProcess.BeginOutputReadLine();
            robocopyProcess.BeginErrorReadLine();

            operationRunning = true;
            btnCopyRight.Enabled = false;
            btnMoveRight.Enabled = false;
            btnCancelOperation.Enabled = true;
        }
        #endregion

        #region Robocopy Process Handlers
        private void RobocopyProcess_OutputDataReceived(object? sender, DataReceivedEventArgs e)
        {
            if (!string.IsNullOrEmpty(e.Data))
            {
                this.Invoke((MethodInvoker)delegate
                {
                    string line = e.Data.Trim();

                    // Extract progress percentage
                    if (line.Contains("%"))
                    {
                        var match = System.Text.RegularExpressions.Regex.Match(line, @"(\d+)%");
                        if (match.Success && int.TryParse(match.Groups[1].Value, out int percent))
                        {
                            progressBar.Value = Math.Min(percent, 100);
                        }
                    }
                    // Filter out robocopy header/footer noise
                    else if (!string.IsNullOrWhiteSpace(line) &&
                             !line.Contains("---------------") &&
                             !line.Contains("ROBOCOPY") &&
                             !line.Contains("Robust File Copy") &&
                             !line.Contains("Started :") &&
                             !line.Contains("Source :") &&
                             !line.Contains("Dest :") &&
                             !line.Contains("Options :") &&
                             !line.Contains("Times") &&
                             !line.Contains("Speed :") &&
                             !line.Contains("Ended :") &&
                             !line.Contains("Total") &&
                             !line.Contains("Dirs :") &&
                             !line.Contains("Files :") &&
                             !line.Contains("Bytes :") &&
                             line.Length > 5)
                    {
                        LogActivity(line);
                    }
                });
            }
        }

        private void RobocopyProcess_ErrorDataReceived(object? sender, DataReceivedEventArgs e)
        {
            if (!string.IsNullOrEmpty(e.Data))
            {
                this.Invoke((MethodInvoker)delegate
                {
                    LogActivity($"Error: {e.Data}");
                });
            }
        }

        private void RobocopyProcess_Exited(object? sender, EventArgs e)
        {
            this.Invoke((MethodInvoker)delegate
            {
                if (robocopyProcess == null) return;

                int exitCode = robocopyProcess.ExitCode;
                progressBar.Value = 100;

                TimeSpan elapsed = DateTime.Now - operationStartTime;
                LogActivity("---");
                LogActivity($"Time: {FormatTime(elapsed.TotalSeconds)}");

                // Interpret robocopy exit code
                string statusMsg = "";
                bool success = true;

                switch (exitCode)
                {
                    case 0:
                        statusMsg = "Completed - No changes needed (all files up to date)";
                        break;
                    case 1:
                        statusMsg = "Completed successfully";
                        break;
                    case 2:
                        statusMsg = "Completed - Extra files/folders in destination";
                        break;
                    case 3:
                        statusMsg = "Completed - Extra files detected";
                        break;
                    case 4:
                        statusMsg = "Warning - Some mismatched files";
                        success = false;
                        break;
                    case 5:
                        statusMsg = "Warning - Some mismatches detected";
                        success = false;
                        break;
                    case 8:
                        statusMsg = "Error - Some files could not be copied";
                        success = false;
                        break;
                    case 16:
                        statusMsg = "Error - Serious error, operation failed";
                        success = false;
                        break;
                    default:
                        statusMsg = $"Completed with exit code: {exitCode}";
                        success = false;
                        break;
                }

                LogActivity(statusMsg);

                // Play sound if enabled
                if (chkSound.Checked)
                {
                    if (success)
                    {
                        Console.Beep(800, 200);
                        System.Threading.Thread.Sleep(50);
                        Console.Beep(1000, 200);
                    }
                    else
                    {
                        Console.Beep(400, 300);
                        System.Threading.Thread.Sleep(50);
                        Console.Beep(400, 300);
                    }
                }

                btnCopyRight.Enabled = true;
                btnMoveRight.Enabled = true;
                btnCancelOperation.Enabled = false;
                operationRunning = false;
                robocopyProcess = null;

                // Refresh destination panel
                if (!string.IsNullOrEmpty(rightPath) && Directory.Exists(rightPath))
                {
                    LoadFolder(listViewRight, rightPath);
                }
            });
        }
        #endregion

        #region ListView Event Handlers
        private void ListView_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateStatusBar();
        }

        private void ListView_DoubleClick(object sender, EventArgs e)
        {
            ListView listView = (ListView)sender;
            if (listView.SelectedItems.Count > 0)
            {
                string fullPath = listView.SelectedItems[0].Tag?.ToString() ?? "";
                if (Directory.Exists(fullPath))
                {
                    if (listView == listViewLeft)
                    {
                        leftPath = fullPath;
                        LoadFolder(listViewLeft, leftPath);
                    }
                    else
                    {
                        rightPath = fullPath;
                        LoadFolder(listViewRight, rightPath);
                    }
                    LogActivity($"Opened folder: {Path.GetFileName(fullPath)}");
                }
            }
        }

        private void ListView_ColumnClick(object sender, ColumnClickEventArgs e)
        {
            ListView listView = (ListView)sender;
            bool isLeft = (listView == listViewLeft);

            if (isLeft)
            {
                if (sortColumnLeft == e.Column)
                {
                    sortDirectionLeft = !sortDirectionLeft;
                }
                else
                {
                    sortColumnLeft = e.Column;
                    sortDirectionLeft = true;
                }
                listView.ListViewItemSorter = new ListViewItemComparer(e.Column, sortDirectionLeft);
            }
            else
            {
                if (sortColumnRight == e.Column)
                {
                    sortDirectionRight = !sortDirectionRight;
                }
                else
                {
                    sortColumnRight = e.Column;
                    sortDirectionRight = true;
                }
                listView.ListViewItemSorter = new ListViewItemComparer(e.Column, sortDirectionRight);
            }

            listView.Sort();
        }
        #endregion

        #region Context Menu Handlers
        private void ListViewContextMenu_Opening(object sender, System.ComponentModel.CancelEventArgs e)
        {
            ContextMenuStrip? menu = sender as ContextMenuStrip;
            ListView? listView = menu?.SourceControl as ListView;

            if (listView == null || listView.SelectedItems.Count == 0)
            {
                e.Cancel = true;
            }
        }

        private void MenuCopyPath_Click(object sender, EventArgs e)
        {
            ToolStripMenuItem? menuItem = sender as ToolStripMenuItem;
            ContextMenuStrip? menu = menuItem?.Owner as ContextMenuStrip;
            ListView? listView = menu?.SourceControl as ListView;

            if (listView != null && listView.SelectedItems.Count > 0)
            {
                StringBuilder paths = new StringBuilder();
                foreach (ListViewItem item in listView.SelectedItems)
                {
                    paths.AppendLine(item.Tag?.ToString() ?? "");
                }
                Clipboard.SetText(paths.ToString().TrimEnd());
                LogActivity($"Copied {listView.SelectedItems.Count} path(s) to clipboard");
            }
        }

        private void MenuOpenExplorer_Click(object sender, EventArgs e)
        {
            ToolStripMenuItem? menuItem = sender as ToolStripMenuItem;
            ContextMenuStrip? menu = menuItem?.Owner as ContextMenuStrip;
            ListView? listView = menu?.SourceControl as ListView;

            if (listView != null && listView.SelectedItems.Count > 0)
            {
                string fullPath = listView.SelectedItems[0].Tag?.ToString() ?? "";
                if (!string.IsNullOrEmpty(fullPath) && (File.Exists(fullPath) || Directory.Exists(fullPath)))
                {
                    Process.Start("explorer.exe", $"/select,\"{fullPath}\"");
                    LogActivity($"Opened in Explorer: {Path.GetFileName(fullPath)}");
                }
            }
        }

        private void MenuDelete_Click(object sender, EventArgs e)
        {
            ToolStripMenuItem? menuItem = sender as ToolStripMenuItem;
            ContextMenuStrip? menu = menuItem?.Owner as ContextMenuStrip;
            ListView? listView = menu?.SourceControl as ListView;

            if (listView != null && listView.SelectedItems.Count > 0)
            {
                DeleteSelected(listView);
            }
        }

        private void MenuProperties_Click(object sender, EventArgs e)
        {
            ToolStripMenuItem? menuItem = sender as ToolStripMenuItem;
            ContextMenuStrip? menu = menuItem?.Owner as ContextMenuStrip;
            ListView? listView = menu?.SourceControl as ListView;

            if (listView != null && listView.SelectedItems.Count > 0)
            {
                string fullPath = listView.SelectedItems[0].Tag?.ToString() ?? "";
                if (!string.IsNullOrEmpty(fullPath))
                {
                    ShowProperties(fullPath);
                }
            }
        }

        private void DeleteSelected(ListView listView)
        {
            string itemText = listView.SelectedItems.Count == 1 ? "this item" : $"these {listView.SelectedItems.Count} items";
            var result = MessageBox.Show(
                $"Are you sure you want to move {itemText} to the Recycle Bin?\n\nYou can restore them from the Recycle Bin if needed.",
                "Confirm Delete",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Warning,
                MessageBoxDefaultButton.Button2);

            if (result == DialogResult.No)
                return;

            int deletedCount = 0;
            int failedCount = 0;

            foreach (ListViewItem item in listView.SelectedItems)
            {
                string fullPath = item.Tag?.ToString() ?? "";
                if (!string.IsNullOrEmpty(fullPath))
                {
                    try
                    {
                        Microsoft.VisualBasic.FileIO.FileSystem.DeleteFile(fullPath,
                            Microsoft.VisualBasic.FileIO.UIOption.OnlyErrorDialogs,
                            Microsoft.VisualBasic.FileIO.RecycleOption.SendToRecycleBin);
                        deletedCount++;
                        LogActivity($"Deleted: {Path.GetFileName(fullPath)}");
                    }
                    catch
                    {
                        failedCount++;
                        LogActivity($"Failed to delete: {Path.GetFileName(fullPath)}");
                    }
                }
            }

            if (failedCount == 0)
            {
                LogActivity($"Successfully deleted {deletedCount} item(s)");
            }
            else
            {
                LogActivity($"Deleted {deletedCount} item(s), failed: {failedCount}");
                MessageBox.Show($"Deleted: {deletedCount}\nFailed: {failedCount}", "Delete Summary", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }

            // Refresh list
            string currentPath = listView == listViewLeft ? leftPath : rightPath;
            LoadFolder(listView, currentPath);
            UpdateStatusBar();
        }

        [DllImport("shell32.dll", CharSet = CharSet.Auto)]
        static extern bool ShellExecuteEx(ref SHELLEXECUTEINFO lpExecInfo);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct SHELLEXECUTEINFO
        {
            public int cbSize;
            public uint fMask;
            public IntPtr hwnd;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpVerb;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpFile;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpParameters;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpDirectory;
            public int nShow;
            public IntPtr hInstApp;
            public IntPtr lpIDList;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpClass;
            public IntPtr hkeyClass;
            public uint dwHotKey;
            public IntPtr hIcon;
            public IntPtr hProcess;
        }

        private void ShowProperties(string path)
        {
            SHELLEXECUTEINFO info = new SHELLEXECUTEINFO();
            info.cbSize = Marshal.SizeOf(info);
            info.lpVerb = "properties";
            info.lpFile = path;
            info.nShow = 5; // SW_SHOW
            info.fMask = 12; // SEE_MASK_INVOKEIDLIST
            ShellExecuteEx(ref info);
            LogActivity($"Opened properties: {Path.GetFileName(path)}");
        }
        #endregion

        #region Keyboard Shortcuts
        protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
        {
            switch (keyData)
            {
                case Keys.Control | Keys.C:
                    if (!operationRunning)
                        CopySelected(false);
                    return true;

                case Keys.Control | Keys.M:
                    if (!operationRunning)
                        CopySelected(true);
                    return true;

                case Keys.Control | Keys.A:
                    foreach (ListViewItem item in listViewLeft.Items)
                        item.Selected = true;
                    UpdateStatusBar();
                    LogActivity("Selected all items in source");
                    return true;

                case Keys.Delete:
                    if (listViewLeft.SelectedItems.Count > 0)
                    {
                        DeleteSelected(listViewLeft);
                        UpdateStatusBar();
                    }
                    return true;

                case Keys.Escape:
                    listViewLeft.SelectedItems.Clear();
                    listViewRight.SelectedItems.Clear();
                    UpdateStatusBar();
                    LogActivity("Deselected all items");
                    return true;

                case Keys.F5:
                    LoadFolder(listViewLeft, leftPath);
                    if (!string.IsNullOrEmpty(rightPath) && Directory.Exists(rightPath))
                        LoadFolder(listViewRight, rightPath);
                    UpdateStatusBar();
                    LogActivity("Lists refreshed");
                    return true;

                case Keys.Enter:
                    if (txtFilter.Focused)
                    {
                        ApplyFileFilter();
                        return true;
                    }
                    break;
            }

            return base.ProcessCmdKey(ref msg, keyData);
        }
        #endregion

        #region Utility Methods
        private void LogActivity(string message)
        {
            string time = DateTime.Now.ToString("HH:mm:ss");
            txtActivity.AppendText($"[{time}] {message}\r\n");
            txtActivity.SelectionStart = txtActivity.Text.Length;
            txtActivity.ScrollToCaret();
        }

        private void UpdateStatusBar()
        {
            int selectedCount = listViewLeft.SelectedItems.Count;
            if (selectedCount > 0)
            {
                long totalSize = 0;
                foreach (ListViewItem item in listViewLeft.SelectedItems)
                {
                    string fullPath = item.Tag?.ToString() ?? "";
                    if (Directory.Exists(fullPath))
                    {
                        totalSize += GetDirectorySize(fullPath);
                    }
                    else if (File.Exists(fullPath))
                    {
                        totalSize += new FileInfo(fullPath).Length;
                    }
                }

                string sizeStr = FormatBytes(totalSize);
                lblStatusBar.Text = $"{selectedCount} item{(selectedCount > 1 ? "s" : "")}\r\n{sizeStr}";
            }
            else
            {
                lblStatusBar.Text = "No items\r\nselected";
            }
        }

        private void UpdateGroupHeaders()
        {
            grpSource.Text = $"Source ({listViewLeft.Items.Count} items)";
            grpDestination.Text = $"Destination ({listViewRight.Items.Count} items)";
        }

        private void ApplyFileFilter()
        {
            fileFilter = txtFilter.Text.Trim();
            LoadFolder(listViewLeft, leftPath);
            if (!string.IsNullOrEmpty(rightPath) && Directory.Exists(rightPath))
                LoadFolder(listViewRight, rightPath);
            UpdateStatusBar();

            if (string.IsNullOrEmpty(fileFilter))
                LogActivity("Filter cleared - showing all files");
            else
                LogActivity($"Filter applied: {fileFilter}");
        }

        private bool MatchesFilter(string fileName)
        {
            if (string.IsNullOrEmpty(fileFilter))
                return true;

            string[] filters = fileFilter.Split(';');
            foreach (string filter in filters)
            {
                string pattern = filter.Trim();
                if (string.IsNullOrEmpty(pattern))
                    continue;

                // Convert wildcard to regex
                pattern = "^" + System.Text.RegularExpressions.Regex.Escape(pattern)
                    .Replace("\\*", ".*")
                    .Replace("\\?", ".") + "$";

                if (System.Text.RegularExpressions.Regex.IsMatch(fileName, pattern, System.Text.RegularExpressions.RegexOptions.IgnoreCase))
                    return true;
            }

            return false;
        }

        private long GetDirectorySize(string path)
        {
            try
            {
                long size = 0;
                DirectoryInfo di = new DirectoryInfo(path);
                foreach (FileInfo fi in di.GetFiles("*", SearchOption.AllDirectories))
                {
                    size += fi.Length;
                }
                return size;
            }
            catch
            {
                return 0;
            }
        }

        private string FormatBytes(long bytes)
        {
            if (bytes < 1024)
                return $"{bytes} B";
            else if (bytes < 1024 * 1024)
                return $"{bytes / 1024.0:F1} KB";
            else if (bytes < 1024 * 1024 * 1024)
                return $"{bytes / (1024.0 * 1024.0):F1} MB";
            else
                return $"{bytes / (1024.0 * 1024.0 * 1024.0):F2} GB";
        }

        private string FormatTime(double seconds)
        {
            if (seconds < 1)
                return $"{Math.Round(seconds * 1000)} ms";
            else if (seconds < 60)
                return $"{seconds:F1} sec";
            else if (seconds < 3600)
            {
                int mins = (int)(seconds / 60);
                int secs = (int)(seconds % 60);
                return $"{mins} min {secs} sec";
            }
            else
            {
                int hours = (int)(seconds / 3600);
                int mins = (int)((seconds % 3600) / 60);
                return $"{hours} h {mins} min";
            }
        }
        #endregion

        #region Settings Persistence
        private void LoadSettings()
        {
            if (!File.Exists(INI_FILE))
                return;

            try
            {
                var lines = File.ReadAllLines(INI_FILE);
                foreach (var line in lines)
                {
                    if (line.Contains("="))
                    {
                        var parts = line.Split('=');
                        string key = parts[0].Trim();
                        string value = parts[1].Trim();

                        switch (key)
                        {
                            case "SourcePath":
                                if (Directory.Exists(value))
                                    leftPath = value;
                                break;
                            case "DestinationPath":
                                if (Directory.Exists(value))
                                    rightPath = value;
                                break;
                            case "WindowX":
                                if (int.TryParse(value, out int x) && x >= 0)
                                    this.StartPosition = FormStartPosition.Manual;
                                    this.Left = x;
                                break;
                            case "WindowY":
                                if (int.TryParse(value, out int y) && y >= 0)
                                    this.Top = y;
                                break;
                            case "NewerFiles":
                                chkNewer.Checked = (value == "1");
                                break;
                            case "Compress":
                                chkCompress.Checked = (value == "1");
                                break;
                            case "Sound":
                                chkSound.Checked = (value == "1");
                                break;
                            case "LastFilter":
                                fileFilter = value;
                                txtFilter.Text = value;
                                break;
                        }
                    }
                }
            }
            catch
            {
                // Ignore errors loading settings
            }
        }

        private void SaveSettings()
        {
            try
            {
                StringBuilder ini = new StringBuilder();
                ini.AppendLine("[Paths]");
                ini.AppendLine($"SourcePath={leftPath}");
                ini.AppendLine($"DestinationPath={rightPath}");
                ini.AppendLine();
                ini.AppendLine("[Window]");
                ini.AppendLine($"WindowX={this.Left}");
                ini.AppendLine($"WindowY={this.Top}");
                ini.AppendLine();
                ini.AppendLine("[Options]");
                ini.AppendLine($"NewerFiles={(chkNewer.Checked ? "1" : "0")}");
                ini.AppendLine($"Compress={(chkCompress.Checked ? "1" : "0")}");
                ini.AppendLine($"Sound={(chkSound.Checked ? "1" : "0")}");
                ini.AppendLine($"LastFilter={fileFilter}");

                File.WriteAllText(INI_FILE, ini.ToString());
                LogActivity($"Settings saved to {INI_FILE}");
            }
            catch (Exception ex)
            {
                LogActivity($"Error saving settings: {ex.Message}");
            }
        }
        #endregion
    }

    #region ListView Sorter
    public class ListViewItemComparer : System.Collections.IComparer
    {
        private int column;
        private bool ascending;

        public ListViewItemComparer(int column, bool ascending)
        {
            this.column = column;
            this.ascending = ascending;
        }

        public int Compare(object? x, object? y)
        {
            if (x == null || y == null)
                return 0;

            ListViewItem itemX = (ListViewItem)x;
            ListViewItem itemY = (ListViewItem)y;

            string textX = itemX.SubItems[column].Text;
            string textY = itemY.SubItems[column].Text;

            int result;

            // Size column - special handling
            if (column == 1)
            {
                if (textX == "<DIR>") textX = "0";
                if (textY == "<DIR>") textY = "0";

                long sizeX = ParseSize(textX);
                long sizeY = ParseSize(textY);
                result = sizeX.CompareTo(sizeY);
            }
            // Date column
            else if (column == 3)
            {
                DateTime dateX = DateTime.TryParse(textX, out DateTime dX) ? dX : DateTime.MinValue;
                DateTime dateY = DateTime.TryParse(textY, out DateTime dY) ? dY : DateTime.MinValue;
                result = dateX.CompareTo(dateY);
            }
            else
            {
                result = String.Compare(textX, textY);
            }

            return ascending ? result : -result;
        }

        private long ParseSize(string sizeText)
        {
            sizeText = sizeText.Trim();
            if (string.IsNullOrEmpty(sizeText) || sizeText == "<DIR>")
                return 0;

            string[] parts = sizeText.Split(' ');
            if (parts.Length != 2)
                return 0;

            if (!double.TryParse(parts[0], out double value))
                return 0;

            switch (parts[1].ToUpper())
            {
                case "B": return (long)value;
                case "KB": return (long)(value * 1024);
                case "MB": return (long)(value * 1024 * 1024);
                case "GB": return (long)(value * 1024 * 1024 * 1024);
                default: return 0;
            }
        }
    }
    #endregion
}
