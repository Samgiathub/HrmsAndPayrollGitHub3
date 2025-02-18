using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080KpipmsKpidevelopmentPlan
{
    public decimal KpiDevelopmentId { get; set; }

    public decimal? KpipmsId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Strengths { get; set; }

    public string? DevelopmentAreas { get; set; }

    public string? ImprovementAction { get; set; }

    public string? Timeline { get; set; }

    public string? Status { get; set; }

    public decimal CmpId { get; set; }

    public int? KpipmsType { get; set; }

    public string? KpipmsName { get; set; }

    public decimal? KpipmsFinancialYr { get; set; }

    public int? KpipmsStatus { get; set; }

    public decimal? KpipmsFinalRating { get; set; }

    public int? KpipmsEmProcessFair { get; set; }

    public int? KpipmsEmpAgree { get; set; }

    public string? KpipmsEmpComments { get; set; }

    public int? KpipmsProcessFairSup { get; set; }

    public int? KpipmsSupAgree { get; set; }

    public string? KpipmsSupComments { get; set; }
}
