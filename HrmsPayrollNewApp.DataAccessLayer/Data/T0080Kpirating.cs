using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080Kpirating
{
    public decimal KpiRatingId { get; set; }

    public decimal CmpId { get; set; }

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

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0080KpipmsEval? Kpipms { get; set; }

    public virtual T0030HrmsRatingMaster? RatingEmployeeNavigation { get; set; }

    public virtual T0030HrmsRatingMaster? RatingManagerNavigation { get; set; }

    public virtual T0030HrmsRatingMaster? RatingNavigation { get; set; }

    public virtual T0080SubKpiMaster? SubKpi { get; set; }
}
