using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080KpipmsKpirating
{
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

    public decimal? KpiRatingId { get; set; }

    public decimal? KpipmsId { get; set; }

    public decimal? SubKpiid { get; set; }

    public decimal? EmpId { get; set; }

    public string? Metric { get; set; }

    public decimal? Rating { get; set; }

    public decimal? AchievedWeight { get; set; }

    public decimal? RatingManager { get; set; }

    public decimal? RatingEmployee { get; set; }

    public string? MetricManager { get; set; }

    public string? MetricEmployee { get; set; }

    public decimal? AchievedWeightManager { get; set; }

    public decimal? AchievedWeightEmp { get; set; }
}
