using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0011LoginHistory
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime LoginDate { get; set; }

    public string IpAddress { get; set; } = null!;

    public string LoginName { get; set; } = null!;

    public string CmpName { get; set; } = null!;
}
