using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0075EmpEarnDeductionApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int AdTranId { get; set; }

    public int CmpId { get; set; }

    public int AdId { get; set; }

    public int IncrementId { get; set; }

    public string EAdFlag { get; set; } = null!;

    public string EAdMode { get; set; } = null!;

    public decimal EAdPercentage { get; set; }

    public decimal EAdAmount { get; set; }

    public decimal EAdMaxLimit { get; set; }

    public decimal EAdYearlyAmount { get; set; }

    public decimal ItEstimatedAmount { get; set; }

    public byte IsCalculateZero { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
