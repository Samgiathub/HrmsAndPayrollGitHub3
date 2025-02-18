using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999LastSynchronization
{
    public decimal RowId { get; set; }

    public string? CmpName { get; set; }

    public string? BranchName { get; set; }

    public string? IpAddress { get; set; }

    public string? LastSync { get; set; }
}
