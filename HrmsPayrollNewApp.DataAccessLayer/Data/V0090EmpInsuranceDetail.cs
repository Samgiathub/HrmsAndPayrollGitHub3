using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpInsuranceDetail
{
    public string InsName { get; set; } = null!;

    public decimal InsTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal EmpInsTranId { get; set; }

    public string InsCmpName { get; set; } = null!;

    public string InsPolicyNo { get; set; } = null!;

    public DateTime? InsTakenDate { get; set; }

    public DateTime? InsDueDate { get; set; }

    public DateTime? InsExpDate { get; set; }

    public decimal InsAmount { get; set; }

    public decimal InsAnualAmt { get; set; }

    public string Type { get; set; } = null!;

    public byte DeductFromSalary { get; set; }

    public decimal MonthlyPremium { get; set; }

    public DateTime? SalEffectiveDate { get; set; }

    public string? EmpDependentId { get; set; }

    public string EmpDependentNameDetail { get; set; } = null!;
}
