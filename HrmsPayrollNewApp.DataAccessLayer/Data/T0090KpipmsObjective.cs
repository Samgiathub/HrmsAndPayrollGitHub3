using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090KpipmsObjective
{
    public decimal KpipmsObjId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? KpipmsId { get; set; }

    public decimal? KpiobjId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Status { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0080Kpiobjective? Kpiobj { get; set; }

    public virtual T0080KpipmsEval? Kpipms { get; set; }
}
