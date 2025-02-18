using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999ReminderMailProfile
{
    public int DbMailProfileId { get; set; }

    public string DbMailProfileName { get; set; } = null!;

    public int CmpId { get; set; }

    public string? EmailId { get; set; }

    public byte[]? Password { get; set; }

    public string? Remark { get; set; }

    public string? ServerLink { get; set; }

    public string? DbBackupPath { get; set; }
}
