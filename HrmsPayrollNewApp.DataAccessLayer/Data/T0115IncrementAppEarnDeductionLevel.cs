using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115IncrementAppEarnDeductionLevel
{
    public decimal AdTranId { get; set; }

    public decimal TranIdLevel { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal AppId { get; set; }

    public DateTime ForDate { get; set; }

    public string EAdFlag { get; set; } = null!;

    public string EAdMode { get; set; } = null!;

    public decimal EAdPercentage { get; set; }

    public decimal EAdAmount { get; set; }

    public decimal EAdMaxLimit { get; set; }

    public decimal EAdYearlyAmount { get; set; }

    public decimal ItEstimatedAmount { get; set; }
}
