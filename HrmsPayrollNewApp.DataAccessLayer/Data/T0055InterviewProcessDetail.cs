using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055InterviewProcessDetail
{
    public decimal InterviewProcessDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecPostId { get; set; }

    public decimal? ProcessId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? SEmpId2 { get; set; }

    public decimal? SEmpId3 { get; set; }

    public decimal? SEmpId4 { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public decimal? DisNo { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040HrmsRProcessMaster? Process { get; set; }

    public virtual T0052HrmsPostedRecruitment RecPost { get; set; } = null!;

    public virtual ICollection<T0055HrmsInterviewScheduleHistory> T0055HrmsInterviewScheduleHistories { get; set; } = new List<T0055HrmsInterviewScheduleHistory>();

    public virtual ICollection<T0055HrmsInterviewSchedule> T0055HrmsInterviewSchedules { get; set; } = new List<T0055HrmsInterviewSchedule>();
}
