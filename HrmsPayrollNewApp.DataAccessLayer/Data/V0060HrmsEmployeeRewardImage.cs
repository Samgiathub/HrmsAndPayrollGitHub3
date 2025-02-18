using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0060HrmsEmployeeRewardImage
{
    public decimal EmpRewardId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? EmployeeId { get; set; }

    public int? Type { get; set; }

    public int? EmpRewardRating { get; set; }

    public decimal? AwardsId { get; set; }

    public string? AwardName { get; set; }

    public string? RewardValuesId { get; set; }

    public string? Comments { get; set; }

    public string? RewardAttachment { get; set; }

    public string? RewardValues { get; set; }

    public string? Employee { get; set; }
}
