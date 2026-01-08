namespace QuickCopy
{
    partial class MainForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.panelTitleBar = new System.Windows.Forms.Panel();
            this.btnClose = new System.Windows.Forms.Button();
            this.btnMinimize = new System.Windows.Forms.Button();
            this.lblTitle = new System.Windows.Forms.Label();
            this.grpSource = new System.Windows.Forms.GroupBox();
            this.listViewLeft = new System.Windows.Forms.ListView();
            this.colLeftName = new System.Windows.Forms.ColumnHeader();
            this.colLeftSize = new System.Windows.Forms.ColumnHeader();
            this.colLeftType = new System.Windows.Forms.ColumnHeader();
            this.colLeftModified = new System.Windows.Forms.ColumnHeader();
            this.contextMenuStrip = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.menuCopyPath = new System.Windows.Forms.ToolStripMenuItem();
            this.menuOpenExplorer = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.menuDelete = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.menuProperties = new System.Windows.Forms.ToolStripMenuItem();
            this.btnLeftBrowse = new System.Windows.Forms.Button();
            this.btnLeftUp = new System.Windows.Forms.Button();
            this.lblLeftPath = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.grpDestination = new System.Windows.Forms.GroupBox();
            this.listViewRight = new System.Windows.Forms.ListView();
            this.colRightName = new System.Windows.Forms.ColumnHeader();
            this.colRightSize = new System.Windows.Forms.ColumnHeader();
            this.colRightType = new System.Windows.Forms.ColumnHeader();
            this.colRightModified = new System.Windows.Forms.ColumnHeader();
            this.btnRightBrowse = new System.Windows.Forms.Button();
            this.btnRightUp = new System.Windows.Forms.Button();
            this.lblRightPath = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.lblStatusBar = new System.Windows.Forms.Label();
            this.btnCopyRight = new System.Windows.Forms.Button();
            this.btnMoveRight = new System.Windows.Forms.Button();
            this.btnSwap = new System.Windows.Forms.Button();
            this.chkSound = new System.Windows.Forms.CheckBox();
            this.grpOptions = new System.Windows.Forms.GroupBox();
            this.btnApplyFilter = new System.Windows.Forms.Button();
            this.txtFilter = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.chkCompress = new System.Windows.Forms.CheckBox();
            this.chkNewer = new System.Windows.Forms.CheckBox();
            this.grpActivity = new System.Windows.Forms.GroupBox();
            this.btnClearActivity = new System.Windows.Forms.Button();
            this.txtActivity = new System.Windows.Forms.TextBox();
            this.btnCancelOperation = new System.Windows.Forms.Button();
            this.progressBar = new System.Windows.Forms.ProgressBar();
            this.lblCopyright = new System.Windows.Forms.Label();
            this.lblAbout = new System.Windows.Forms.Label();
            this.panelTitleBar.SuspendLayout();
            this.grpSource.SuspendLayout();
            this.contextMenuStrip.SuspendLayout();
            this.grpDestination.SuspendLayout();
            this.grpOptions.SuspendLayout();
            this.grpActivity.SuspendLayout();
            this.SuspendLayout();
            //
            // panelTitleBar
            //
            this.panelTitleBar.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(32)))), ((int)(((byte)(113)))), ((int)(((byte)(181)))));
            this.panelTitleBar.Controls.Add(this.btnClose);
            this.panelTitleBar.Controls.Add(this.btnMinimize);
            this.panelTitleBar.Controls.Add(this.lblTitle);
            this.panelTitleBar.Location = new System.Drawing.Point(0, 0);
            this.panelTitleBar.Name = "panelTitleBar";
            this.panelTitleBar.Size = new System.Drawing.Size(1100, 35);
            this.panelTitleBar.TabIndex = 0;
            this.panelTitleBar.MouseDown += new System.Windows.Forms.MouseEventHandler(this.PanelTitleBar_MouseDown);
            this.panelTitleBar.MouseMove += new System.Windows.Forms.MouseEventHandler(this.PanelTitleBar_MouseMove);
            this.panelTitleBar.MouseUp += new System.Windows.Forms.MouseEventHandler(this.PanelTitleBar_MouseUp);
            //
            // btnClose
            //
            this.btnClose.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(32)))), ((int)(((byte)(113)))), ((int)(((byte)(181)))));
            this.btnClose.FlatAppearance.BorderSize = 0;
            this.btnClose.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnClose.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.btnClose.ForeColor = System.Drawing.Color.White;
            this.btnClose.Location = new System.Drawing.Point(1060, 5);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(35, 25);
            this.btnClose.TabIndex = 2;
            this.btnClose.Text = "✕";
            this.btnClose.UseVisualStyleBackColor = false;
            this.btnClose.Click += new System.EventHandler(this.BtnClose_Click);
            //
            // btnMinimize
            //
            this.btnMinimize.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(32)))), ((int)(((byte)(113)))), ((int)(((byte)(181)))));
            this.btnMinimize.FlatAppearance.BorderSize = 0;
            this.btnMinimize.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMinimize.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.btnMinimize.ForeColor = System.Drawing.Color.White;
            this.btnMinimize.Location = new System.Drawing.Point(1020, 5);
            this.btnMinimize.Name = "btnMinimize";
            this.btnMinimize.Size = new System.Drawing.Size(35, 25);
            this.btnMinimize.TabIndex = 1;
            this.btnMinimize.Text = "—";
            this.btnMinimize.UseVisualStyleBackColor = false;
            this.btnMinimize.Click += new System.EventHandler(this.BtnMinimize_Click);
            //
            // lblTitle
            //
            this.lblTitle.AutoSize = true;
            this.lblTitle.Font = new System.Drawing.Font("Segoe UI", 11F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
            this.lblTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(218)))), ((int)(((byte)(0)))));
            this.lblTitle.Location = new System.Drawing.Point(10, 8);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(263, 20);
            this.lblTitle.TabIndex = 0;
            this.lblTitle.Text = "⚡ QuickCopy Vattenfall Edition";
            //
            // grpSource
            //
            this.grpSource.Controls.Add(this.listViewLeft);
            this.grpSource.Controls.Add(this.btnLeftBrowse);
            this.grpSource.Controls.Add(this.btnLeftUp);
            this.grpSource.Controls.Add(this.lblLeftPath);
            this.grpSource.Controls.Add(this.label1);
            this.grpSource.Location = new System.Drawing.Point(5, 38);
            this.grpSource.Name = "grpSource";
            this.grpSource.Size = new System.Drawing.Size(490, 427);
            this.grpSource.TabIndex = 1;
            this.grpSource.TabStop = false;
            this.grpSource.Text = "Source";
            //
            // listViewLeft
            //
            this.listViewLeft.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.colLeftName,
            this.colLeftSize,
            this.colLeftType,
            this.colLeftModified});
            this.listViewLeft.ContextMenuStrip = this.contextMenuStrip;
            this.listViewLeft.FullRowSelect = true;
            this.listViewLeft.GridLines = true;
            this.listViewLeft.Location = new System.Drawing.Point(5, 45);
            this.listViewLeft.Name = "listViewLeft";
            this.listViewLeft.Size = new System.Drawing.Size(480, 375);
            this.listViewLeft.TabIndex = 4;
            this.listViewLeft.UseCompatibleStateImageBehavior = false;
            this.listViewLeft.View = System.Windows.Forms.View.Details;
            this.listViewLeft.ColumnClick += new System.Windows.Forms.ColumnClickEventHandler(this.ListView_ColumnClick);
            this.listViewLeft.SelectedIndexChanged += new System.EventHandler(this.ListView_SelectedIndexChanged);
            this.listViewLeft.DoubleClick += new System.EventHandler(this.ListView_DoubleClick);
            //
            // colLeftName
            //
            this.colLeftName.Text = "Name";
            this.colLeftName.Width = 206;
            //
            // colLeftSize
            //
            this.colLeftSize.Text = "Size";
            this.colLeftSize.Width = 70;
            //
            // colLeftType
            //
            this.colLeftType.Text = "Type";
            this.colLeftType.Width = 60;
            //
            // colLeftModified
            //
            this.colLeftModified.Text = "Modified";
            this.colLeftModified.Width = 140;
            //
            // contextMenuStrip
            //
            this.contextMenuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuCopyPath,
            this.menuOpenExplorer,
            this.toolStripSeparator1,
            this.menuDelete,
            this.toolStripSeparator2,
            this.menuProperties});
            this.contextMenuStrip.Name = "contextMenuStrip";
            this.contextMenuStrip.Size = new System.Drawing.Size(172, 104);
            this.contextMenuStrip.Opening += new System.ComponentModel.CancelEventHandler(this.ListViewContextMenu_Opening);
            //
            // menuCopyPath
            //
            this.menuCopyPath.Name = "menuCopyPath";
            this.menuCopyPath.Size = new System.Drawing.Size(171, 22);
            this.menuCopyPath.Text = "Copy Path";
            this.menuCopyPath.Click += new System.EventHandler(this.MenuCopyPath_Click);
            //
            // menuOpenExplorer
            //
            this.menuOpenExplorer.Name = "menuOpenExplorer";
            this.menuOpenExplorer.Size = new System.Drawing.Size(171, 22);
            this.menuOpenExplorer.Text = "Open in Explorer";
            this.menuOpenExplorer.Click += new System.EventHandler(this.MenuOpenExplorer_Click);
            //
            // toolStripSeparator1
            //
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(168, 6);
            //
            // menuDelete
            //
            this.menuDelete.Name = "menuDelete";
            this.menuDelete.Size = new System.Drawing.Size(171, 22);
            this.menuDelete.Text = "Delete";
            this.menuDelete.Click += new System.EventHandler(this.MenuDelete_Click);
            //
            // toolStripSeparator2
            //
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(168, 6);
            //
            // menuProperties
            //
            this.menuProperties.Name = "menuProperties";
            this.menuProperties.Size = new System.Drawing.Size(171, 22);
            this.menuProperties.Text = "Properties";
            this.menuProperties.Click += new System.EventHandler(this.MenuProperties_Click);
            //
            // btnLeftBrowse
            //
            this.btnLeftBrowse.Location = new System.Drawing.Point(410, 14);
            this.btnLeftBrowse.Name = "btnLeftBrowse";
            this.btnLeftBrowse.Size = new System.Drawing.Size(75, 25);
            this.btnLeftBrowse.TabIndex = 3;
            this.btnLeftBrowse.Text = "Browse";
            this.btnLeftBrowse.UseVisualStyleBackColor = true;
            this.btnLeftBrowse.Click += new System.EventHandler(this.BtnLeftBrowse_Click);
            //
            // btnLeftUp
            //
            this.btnLeftUp.Location = new System.Drawing.Point(365, 14);
            this.btnLeftUp.Name = "btnLeftUp";
            this.btnLeftUp.Size = new System.Drawing.Size(40, 25);
            this.btnLeftUp.TabIndex = 2;
            this.btnLeftUp.Text = "↑ Up";
            this.btnLeftUp.UseVisualStyleBackColor = true;
            this.btnLeftUp.Click += new System.EventHandler(this.BtnLeftUp_Click);
            //
            // lblLeftPath
            //
            this.lblLeftPath.AutoSize = true;
            this.lblLeftPath.Location = new System.Drawing.Point(65, 19);
            this.lblLeftPath.Name = "lblLeftPath";
            this.lblLeftPath.Size = new System.Drawing.Size(38, 15);
            this.lblLeftPath.TabIndex = 1;
            this.lblLeftPath.Text = "label3";
            //
            // label1
            //
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(10, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(43, 15);
            this.label1.TabIndex = 0;
            this.label1.Text = "Folder:";
            //
            // grpDestination
            //
            this.grpDestination.Controls.Add(this.listViewRight);
            this.grpDestination.Controls.Add(this.btnRightBrowse);
            this.grpDestination.Controls.Add(this.btnRightUp);
            this.grpDestination.Controls.Add(this.lblRightPath);
            this.grpDestination.Controls.Add(this.label2);
            this.grpDestination.Location = new System.Drawing.Point(605, 38);
            this.grpDestination.Name = "grpDestination";
            this.grpDestination.Size = new System.Drawing.Size(490, 427);
            this.grpDestination.TabIndex = 2;
            this.grpDestination.TabStop = false;
            this.grpDestination.Text = "Destination";
            //
            // listViewRight
            //
            this.listViewRight.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.colRightName,
            this.colRightSize,
            this.colRightType,
            this.colRightModified});
            this.listViewRight.ContextMenuStrip = this.contextMenuStrip;
            this.listViewRight.FullRowSelect = true;
            this.listViewRight.GridLines = true;
            this.listViewRight.Location = new System.Drawing.Point(5, 45);
            this.listViewRight.Name = "listViewRight";
            this.listViewRight.Size = new System.Drawing.Size(480, 375);
            this.listViewRight.TabIndex = 4;
            this.listViewRight.UseCompatibleStateImageBehavior = false;
            this.listViewRight.View = System.Windows.Forms.View.Details;
            this.listViewRight.ColumnClick += new System.Windows.Forms.ColumnClickEventHandler(this.ListView_ColumnClick);
            this.listViewRight.SelectedIndexChanged += new System.EventHandler(this.ListView_SelectedIndexChanged);
            this.listViewRight.DoubleClick += new System.EventHandler(this.ListView_DoubleClick);
            //
            // colRightName
            //
            this.colRightName.Text = "Name";
            this.colRightName.Width = 206;
            //
            // colRightSize
            //
            this.colRightSize.Text = "Size";
            this.colRightSize.Width = 70;
            //
            // colRightType
            //
            this.colRightType.Text = "Type";
            this.colRightType.Width = 60;
            //
            // colRightModified
            //
            this.colRightModified.Text = "Modified";
            this.colRightModified.Width = 140;
            //
            // btnRightBrowse
            //
            this.btnRightBrowse.Location = new System.Drawing.Point(390, 14);
            this.btnRightBrowse.Name = "btnRightBrowse";
            this.btnRightBrowse.Size = new System.Drawing.Size(75, 25);
            this.btnRightBrowse.TabIndex = 3;
            this.btnRightBrowse.Text = "Browse";
            this.btnRightBrowse.UseVisualStyleBackColor = true;
            this.btnRightBrowse.Click += new System.EventHandler(this.BtnRightBrowse_Click);
            //
            // btnRightUp
            //
            this.btnRightUp.Location = new System.Drawing.Point(345, 14);
            this.btnRightUp.Name = "btnRightUp";
            this.btnRightUp.Size = new System.Drawing.Size(40, 25);
            this.btnRightUp.TabIndex = 2;
            this.btnRightUp.Text = "↑ Up";
            this.btnRightUp.UseVisualStyleBackColor = true;
            this.btnRightUp.Click += new System.EventHandler(this.BtnRightUp_Click);
            //
            // lblRightPath
            //
            this.lblRightPath.AutoSize = true;
            this.lblRightPath.Location = new System.Drawing.Point(65, 19);
            this.lblRightPath.Name = "lblRightPath";
            this.lblRightPath.Size = new System.Drawing.Size(135, 15);
            this.lblRightPath.TabIndex = 1;
            this.lblRightPath.Text = "No destination selected";
            //
            // label2
            //
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(10, 19);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(43, 15);
            this.label2.TabIndex = 0;
            this.label2.Text = "Folder:";
            //
            // lblStatusBar
            //
            this.lblStatusBar.Font = new System.Drawing.Font("Segoe UI", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.lblStatusBar.Location = new System.Drawing.Point(495, 160);
            this.lblStatusBar.Name = "lblStatusBar";
            this.lblStatusBar.Size = new System.Drawing.Size(110, 30);
            this.lblStatusBar.TabIndex = 3;
            this.lblStatusBar.Text = "No items\r\nselected";
            this.lblStatusBar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            //
            // btnCopyRight
            //
            this.btnCopyRight.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(218)))), ((int)(((byte)(0)))));
            this.btnCopyRight.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
            this.btnCopyRight.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(78)))), ((int)(((byte)(75)))), ((int)(((byte)(72)))));
            this.btnCopyRight.Location = new System.Drawing.Point(493, 195);
            this.btnCopyRight.Name = "btnCopyRight";
            this.btnCopyRight.Size = new System.Drawing.Size(114, 65);
            this.btnCopyRight.TabIndex = 4;
            this.btnCopyRight.Text = "COPY\r\n►";
            this.btnCopyRight.UseVisualStyleBackColor = false;
            this.btnCopyRight.Click += new System.EventHandler(this.BtnCopyRight_Click);
            //
            // btnMoveRight
            //
            this.btnMoveRight.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(32)))), ((int)(((byte)(113)))), ((int)(((byte)(181)))));
            this.btnMoveRight.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
            this.btnMoveRight.ForeColor = System.Drawing.Color.White;
            this.btnMoveRight.Location = new System.Drawing.Point(493, 270);
            this.btnMoveRight.Name = "btnMoveRight";
            this.btnMoveRight.Size = new System.Drawing.Size(114, 65);
            this.btnMoveRight.TabIndex = 5;
            this.btnMoveRight.Text = "MOVE\r\n►";
            this.btnMoveRight.UseVisualStyleBackColor = false;
            this.btnMoveRight.Click += new System.EventHandler(this.BtnMoveRight_Click);
            //
            // btnSwap
            //
            this.btnSwap.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
            this.btnSwap.Location = new System.Drawing.Point(493, 345);
            this.btnSwap.Name = "btnSwap";
            this.btnSwap.Size = new System.Drawing.Size(114, 35);
            this.btnSwap.TabIndex = 6;
            this.btnSwap.Text = "⇄ Swap";
            this.btnSwap.UseVisualStyleBackColor = true;
            this.btnSwap.Click += new System.EventHandler(this.BtnSwap_Click);
            //
            // chkSound
            //
            this.chkSound.AutoSize = true;
            this.chkSound.Checked = true;
            this.chkSound.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkSound.Location = new System.Drawing.Point(510, 390);
            this.chkSound.Name = "chkSound";
            this.chkSound.Size = new System.Drawing.Size(60, 19);
            this.chkSound.TabIndex = 7;
            this.chkSound.Text = "Sound";
            this.chkSound.UseVisualStyleBackColor = true;
            //
            // grpOptions
            //
            this.grpOptions.Controls.Add(this.btnApplyFilter);
            this.grpOptions.Controls.Add(this.txtFilter);
            this.grpOptions.Controls.Add(this.label3);
            this.grpOptions.Controls.Add(this.chkCompress);
            this.grpOptions.Controls.Add(this.chkNewer);
            this.grpOptions.Location = new System.Drawing.Point(5, 470);
            this.grpOptions.Name = "grpOptions";
            this.grpOptions.Size = new System.Drawing.Size(1090, 35);
            this.grpOptions.TabIndex = 8;
            this.grpOptions.TabStop = false;
            this.grpOptions.Text = "Options";
            //
            // btnApplyFilter
            //
            this.btnApplyFilter.Location = new System.Drawing.Point(1035, 10);
            this.btnApplyFilter.Name = "btnApplyFilter";
            this.btnApplyFilter.Size = new System.Drawing.Size(50, 22);
            this.btnApplyFilter.TabIndex = 4;
            this.btnApplyFilter.Text = "Apply";
            this.btnApplyFilter.UseVisualStyleBackColor = true;
            this.btnApplyFilter.Click += new System.EventHandler(this.BtnApplyFilter_Click);
            //
            // txtFilter
            //
            this.txtFilter.Location = new System.Drawing.Point(540, 10);
            this.txtFilter.Name = "txtFilter";
            this.txtFilter.Size = new System.Drawing.Size(490, 23);
            this.txtFilter.TabIndex = 3;
            //
            // label3
            //
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(500, 13);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(36, 15);
            this.label3.TabIndex = 2;
            this.label3.Text = "Filter:";
            //
            // chkCompress
            //
            this.chkCompress.AutoSize = true;
            this.chkCompress.Location = new System.Drawing.Point(220, 12);
            this.chkCompress.Name = "chkCompress";
            this.chkCompress.Size = new System.Drawing.Size(229, 19);
            this.chkCompress.TabIndex = 1;
            this.chkCompress.Text = "Compress for network (/COMPRESS)";
            this.chkCompress.UseVisualStyleBackColor = true;
            //
            // chkNewer
            //
            this.chkNewer.AutoSize = true;
            this.chkNewer.Location = new System.Drawing.Point(10, 12);
            this.chkNewer.Name = "chkNewer";
            this.chkNewer.Size = new System.Drawing.Size(157, 19);
            this.chkNewer.TabIndex = 0;
            this.chkNewer.Text = "Only newer files (/XO)";
            this.chkNewer.UseVisualStyleBackColor = true;
            //
            // grpActivity
            //
            this.grpActivity.Controls.Add(this.btnClearActivity);
            this.grpActivity.Controls.Add(this.txtActivity);
            this.grpActivity.Controls.Add(this.btnCancelOperation);
            this.grpActivity.Controls.Add(this.progressBar);
            this.grpActivity.Location = new System.Drawing.Point(5, 510);
            this.grpActivity.Name = "grpActivity";
            this.grpActivity.Size = new System.Drawing.Size(1090, 160);
            this.grpActivity.TabIndex = 9;
            this.grpActivity.TabStop = false;
            this.grpActivity.Text = "Activity Log";
            //
            // btnClearActivity
            //
            this.btnClearActivity.Location = new System.Drawing.Point(1000, 130);
            this.btnClearActivity.Name = "btnClearActivity";
            this.btnClearActivity.Size = new System.Drawing.Size(80, 25);
            this.btnClearActivity.TabIndex = 3;
            this.btnClearActivity.Text = "Clear Log";
            this.btnClearActivity.UseVisualStyleBackColor = true;
            this.btnClearActivity.Click += new System.EventHandler(this.BtnClearActivity_Click);
            //
            // txtActivity
            //
            this.txtActivity.BackColor = System.Drawing.Color.White;
            this.txtActivity.Location = new System.Drawing.Point(5, 42);
            this.txtActivity.Multiline = true;
            this.txtActivity.Name = "txtActivity";
            this.txtActivity.ReadOnly = true;
            this.txtActivity.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.txtActivity.Size = new System.Drawing.Size(1080, 85);
            this.txtActivity.TabIndex = 2;
            //
            // btnCancelOperation
            //
            this.btnCancelOperation.Location = new System.Drawing.Point(1010, 12);
            this.btnCancelOperation.Name = "btnCancelOperation";
            this.btnCancelOperation.Size = new System.Drawing.Size(70, 28);
            this.btnCancelOperation.TabIndex = 1;
            this.btnCancelOperation.Text = "Cancel";
            this.btnCancelOperation.UseVisualStyleBackColor = true;
            this.btnCancelOperation.Click += new System.EventHandler(this.BtnCancelOperation_Click);
            //
            // progressBar
            //
            this.progressBar.Location = new System.Drawing.Point(15, 14);
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(990, 25);
            this.progressBar.TabIndex = 0;
            //
            // lblCopyright
            //
            this.lblCopyright.AutoSize = true;
            this.lblCopyright.Location = new System.Drawing.Point(10, 675);
            this.lblCopyright.Name = "lblCopyright";
            this.lblCopyright.Size = new System.Drawing.Size(77, 15);
            this.lblCopyright.TabIndex = 10;
            this.lblCopyright.Text = "© 2025 YISPC";
            //
            // lblAbout
            //
            this.lblAbout.AutoSize = true;
            this.lblAbout.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblAbout.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.lblAbout.Location = new System.Drawing.Point(105, 673);
            this.lblAbout.Name = "lblAbout";
            this.lblAbout.Size = new System.Drawing.Size(25, 21);
            this.lblAbout.TabIndex = 11;
            this.lblAbout.Text = "ℹ️";
            this.lblAbout.Click += new System.EventHandler(this.BtnAbout_Click);
            //
            // MainForm
            //
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1100, 700);
            this.Controls.Add(this.lblAbout);
            this.Controls.Add(this.lblCopyright);
            this.Controls.Add(this.grpActivity);
            this.Controls.Add(this.grpOptions);
            this.Controls.Add(this.chkSound);
            this.Controls.Add(this.btnSwap);
            this.Controls.Add(this.btnMoveRight);
            this.Controls.Add(this.btnCopyRight);
            this.Controls.Add(this.lblStatusBar);
            this.Controls.Add(this.grpDestination);
            this.Controls.Add(this.grpSource);
            this.Controls.Add(this.panelTitleBar);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "MainForm";
            this.Text = "QuickCopy Vattenfall Edition";
            this.panelTitleBar.ResumeLayout(false);
            this.panelTitleBar.PerformLayout();
            this.grpSource.ResumeLayout(false);
            this.grpSource.PerformLayout();
            this.contextMenuStrip.ResumeLayout(false);
            this.grpDestination.ResumeLayout(false);
            this.grpDestination.PerformLayout();
            this.grpOptions.ResumeLayout(false);
            this.grpOptions.PerformLayout();
            this.grpActivity.ResumeLayout(false);
            this.grpActivity.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel panelTitleBar;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.Button btnMinimize;
        private System.Windows.Forms.Label lblTitle;
        private System.Windows.Forms.GroupBox grpSource;
        private System.Windows.Forms.ListView listViewLeft;
        private System.Windows.Forms.ColumnHeader colLeftName;
        private System.Windows.Forms.ColumnHeader colLeftSize;
        private System.Windows.Forms.ColumnHeader colLeftType;
        private System.Windows.Forms.ColumnHeader colLeftModified;
        private System.Windows.Forms.Button btnLeftBrowse;
        private System.Windows.Forms.Button btnLeftUp;
        private System.Windows.Forms.Label lblLeftPath;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.GroupBox grpDestination;
        private System.Windows.Forms.ListView listViewRight;
        private System.Windows.Forms.ColumnHeader colRightName;
        private System.Windows.Forms.ColumnHeader colRightSize;
        private System.Windows.Forms.ColumnHeader colRightType;
        private System.Windows.Forms.ColumnHeader colRightModified;
        private System.Windows.Forms.Button btnRightBrowse;
        private System.Windows.Forms.Button btnRightUp;
        private System.Windows.Forms.Label lblRightPath;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label lblStatusBar;
        private System.Windows.Forms.Button btnCopyRight;
        private System.Windows.Forms.Button btnMoveRight;
        private System.Windows.Forms.Button btnSwap;
        private System.Windows.Forms.CheckBox chkSound;
        private System.Windows.Forms.GroupBox grpOptions;
        private System.Windows.Forms.Button btnApplyFilter;
        private System.Windows.Forms.TextBox txtFilter;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.CheckBox chkCompress;
        private System.Windows.Forms.CheckBox chkNewer;
        private System.Windows.Forms.GroupBox grpActivity;
        private System.Windows.Forms.Button btnClearActivity;
        private System.Windows.Forms.TextBox txtActivity;
        private System.Windows.Forms.Button btnCancelOperation;
        private System.Windows.Forms.ProgressBar progressBar;
        private System.Windows.Forms.Label lblCopyright;
        private System.Windows.Forms.Label lblAbout;
        private System.Windows.Forms.ContextMenuStrip contextMenuStrip;
        private System.Windows.Forms.ToolStripMenuItem menuCopyPath;
        private System.Windows.Forms.ToolStripMenuItem menuOpenExplorer;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem menuDelete;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripMenuItem menuProperties;
    }
}
