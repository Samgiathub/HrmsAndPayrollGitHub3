using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsKpa
{
    public decimal KpaId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? InitiateId { get; set; }

    public decimal? EmpId { get; set; }

    public string? KpaContent { get; set; }

    public decimal? KpaAchievement { get; set; }

    public string? KpaCritical { get; set; }

    public string? KpaTarget { get; set; }

    public decimal? KpaWeightage { get; set; }

    public decimal? KpaAchievementEmp { get; set; }

    public decimal? KpaAchievementRm { get; set; }

    public string? RmComments { get; set; }

    public decimal? RmWeightage { get; set; }

    public decimal? RmRating { get; set; }

    public decimal? HodWeightage { get; set; }

    public decimal? HodRating { get; set; }

    public decimal? KpaAchievementHod { get; set; }

    public string? HodComments { get; set; }

    public decimal? GhWeightage { get; set; }

    public decimal? GhRating { get; set; }

    public decimal? KpaAchievementGh { get; set; }

    public string? GhComments { get; set; }

    public decimal? KpaTypeId { get; set; }

    public string? ActualAchievement { get; set; }

    public string? KpaPerformaceMeasure { get; set; }

    public decimal? AchievementPercentageEmp { get; set; }

    public decimal? AchievementPercentageRm { get; set; }

    public decimal? AchievementPercentageHod { get; set; }

    public decimal? AchievementPercentageGh { get; set; }

    public DateTime? CompletionDate { get; set; }

    public string? AttachDocs { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0050HrmsInitiateAppraisal? Initiate { get; set; }

    public virtual T0040HrmsKpatypeMaster? KpaType { get; set; }
}
