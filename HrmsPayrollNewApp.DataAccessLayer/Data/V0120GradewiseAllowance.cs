using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120GradewiseAllowance
{
    public decimal CmpId { get; set; }

    public decimal? GrdId { get; set; }

    public DateTime SysDate { get; set; }

    public decimal TranId { get; set; }

    public string AdName { get; set; } = null!;

    public decimal AdId { get; set; }

    public string AdSortName { get; set; } = null!;

    public decimal AdLevel { get; set; }

    public string AdMode { get; set; } = null!;

    public string AdCalculateOn { get; set; } = null!;

    public string AdFlag { get; set; } = null!;

    public decimal AdPercentage { get; set; }

    public decimal AdAmount { get; set; }

    public decimal AdActive { get; set; }

    public decimal AdMaxLimit { get; set; }

    public decimal? AdDefId { get; set; }

    public string? AdEffectMonth { get; set; }

    public decimal? AdEffectOnCtc { get; set; }

    public byte? AdRptDefId { get; set; }

    public byte? AdItDefId { get; set; }

    public byte? AdEffectOnShortFall { get; set; }

    public byte? AdEffectOnGratuity { get; set; }

    public byte? AdEffectOnBonus { get; set; }

    public byte? AdEffectOnLeave { get; set; }

    public byte? AdEffectOnLate { get; set; }

    public decimal? AdEffectOnExtraDay { get; set; }

    public decimal? AdEffectOnOt { get; set; }

    public decimal? AdNotEffectSalary { get; set; }

    public decimal? AdNotEffectOnPt { get; set; }

    public decimal? Expr1 { get; set; }

    public byte? IsOptional { get; set; }
}
