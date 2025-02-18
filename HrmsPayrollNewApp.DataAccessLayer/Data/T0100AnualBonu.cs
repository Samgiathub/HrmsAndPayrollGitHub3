using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100AnualBonu
{
    public decimal BonusTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal Amount { get; set; }

    public decimal EffectiveMonth { get; set; }

    public decimal EffectiveYear { get; set; }

    public decimal SalTranId { get; set; }

    public DateTime SysDate { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
