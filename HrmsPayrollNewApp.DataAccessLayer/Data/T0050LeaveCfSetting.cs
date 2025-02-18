using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050LeaveCfSetting
{
    public decimal LeaveId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal FromPdays { get; set; }

    public decimal ToPdays { get; set; }

    public decimal CfDays { get; set; }

    public decimal CfFullDays { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;
}
