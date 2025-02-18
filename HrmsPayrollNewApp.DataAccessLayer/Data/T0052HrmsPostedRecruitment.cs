using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsPostedRecruitment
{
    public decimal RecPostId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecReqId { get; set; }

    public string RecPostCode { get; set; } = null!;

    public DateTime RecPostDate { get; set; }

    public DateTime RecStartDate { get; set; }

    public DateTime? RecEndDate { get; set; }

    public string QualDetail { get; set; } = null!;

    public decimal ExperienceYear { get; set; }

    public string? Location { get; set; }

    public string Experience { get; set; } = null!;

    public string EmailId { get; set; } = null!;

    public string JobTitle { get; set; } = null!;

    public byte PostedStatus { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? OtherDetail { get; set; }

    public string? Position { get; set; }

    public string? VenueAddress { get; set; }

    public int? PublishToEmp { get; set; }

    public DateTime? PublishFromDate { get; set; }

    public DateTime? PublishToDate { get; set; }

    public int? ConsultantId { get; set; }

    public double? ExpMin { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login? Login { get; set; }

    public virtual T0050HrmsRecruitmentRequest RecReq { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0040HrmsGeneralSetting> T0040HrmsGeneralSettings { get; set; } = new List<T0040HrmsGeneralSetting>();

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0053HrmsRecruitmentForm> T0053HrmsRecruitmentForms { get; set; } = new List<T0053HrmsRecruitmentForm>();

    public virtual ICollection<T0055HrmsInterviewScheduleHistory> T0055HrmsInterviewScheduleHistories { get; set; } = new List<T0055HrmsInterviewScheduleHistory>();

    public virtual ICollection<T0055HrmsInterviewSchedule> T0055HrmsInterviewSchedules { get; set; } = new List<T0055HrmsInterviewSchedule>();

    public virtual ICollection<T0055InterviewProcessDetail> T0055InterviewProcessDetails { get; set; } = new List<T0055InterviewProcessDetail>();

    public virtual ICollection<T0055InterviewProcessQuestionDetail> T0055InterviewProcessQuestionDetails { get; set; } = new List<T0055InterviewProcessQuestionDetail>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();
}
