using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class VoptionalAllowanceGradewise
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal? GrdId { get; set; }

    public DateTime SysDate { get; set; }

    public decimal? AdLevel { get; set; }

    public string? AdMode { get; set; }

    public decimal? AdPercentage { get; set; }

    public decimal? AdAmount { get; set; }

    public decimal? AdMaxLimit { get; set; }

    public decimal? AdNonTaxLimit { get; set; }

    public decimal AdMaxLimitNotNull { get; set; }

    public string AdName { get; set; } = null!;

    public string AdFlag { get; set; } = null!;

    public string AdSortName { get; set; } = null!;

    public byte IsOptional { get; set; }

    public decimal EligibilityAmount { get; set; }

    public string? EmpFullNameNew { get; set; }

    public decimal EmpId { get; set; }

    public string AdCalculateOn { get; set; } = null!;

    public string AdCode { get; set; } = null!;

    public string AllowanceType { get; set; } = null!;
}
