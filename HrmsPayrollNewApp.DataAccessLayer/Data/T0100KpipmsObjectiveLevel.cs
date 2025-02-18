using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100KpipmsObjectiveLevel
{
    public decimal RowId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? TranId { get; set; }

    public decimal? KpiobjId { get; set; }

    public string? Status { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080Kpiobjective? Kpiobj { get; set; }

    public virtual T0090KpipmsEvalApproval? Tran { get; set; }
}
