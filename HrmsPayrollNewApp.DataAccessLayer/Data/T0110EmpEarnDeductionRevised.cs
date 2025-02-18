using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110EmpEarnDeductionRevised
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime ForDate { get; set; }

    public string EAdFlag { get; set; } = null!;

    public string EAdMode { get; set; } = null!;

    public decimal? EAdPercentage { get; set; }

    public decimal EAdAmount { get; set; }

    public decimal EAdMaxLimit { get; set; }

    public decimal EAdYearlyAmount { get; set; }

    public string EntryType { get; set; } = null!;

    public decimal? IncrementId { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? UserId { get; set; }

    public byte IsCalculateZero { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
