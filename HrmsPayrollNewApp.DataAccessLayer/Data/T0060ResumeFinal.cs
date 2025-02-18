using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060ResumeFinal
{
    public decimal TranId { get; set; }

    public decimal ResumeId { get; set; }

    public int? ResumeStatus { get; set; }

    public decimal CmpId { get; set; }

    public decimal? RecPostId { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? Comments { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public int? Acceptance { get; set; }

    public DateTime? AcceptanceDate { get; set; }

    public int? MedicalInspection { get; set; }

    public int? PoliceIncpection { get; set; }

    public string? Ref1 { get; set; }

    public string? Ref2 { get; set; }

    public DateTime? JoiningDate { get; set; }

    public decimal? BasicSalay { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? JoiningStatus { get; set; }

    public decimal? TotalCtc { get; set; }

    public decimal? ReportingManagerId { get; set; }

    public decimal? BusinessHead { get; set; }

    public int? Level2Approval { get; set; }

    public decimal? SalaryCycleId { get; set; }

    public decimal? ShiftId { get; set; }

    public decimal? EmploymentTypeId { get; set; }

    public decimal? BusinessSegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? PaymentMode { get; set; }

    public decimal? BankId { get; set; }

    public string? AccountNoBank { get; set; }

    public string? Remarks { get; set; }

    public int? FinalStatus { get; set; }

    public decimal? ApprovedBy { get; set; }

    public int? IsEmployee { get; set; }

    public decimal? SalaryRule { get; set; }

    public decimal? AssignedCmpid { get; set; }

    public decimal ConfirmEmpId { get; set; }

    public decimal? LatterFormat { get; set; }

    public string? LatterfileName { get; set; }

    public string? SalaryFileName { get; set; }

    public decimal NoticePeriod { get; set; }

    public decimal? RCmpId { get; set; }

    public decimal? AppointmentLetterFormat { get; set; }

    public string? AppointmentLetterFile { get; set; }

    public decimal? AcceptAppointment { get; set; }

    public int? BackgroundVerification { get; set; }

    public DateTime? OfferDate { get; set; }

    public string? IfscCode { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? SEmpId { get; set; }

    public int? CategoryId { get; set; }

    public virtual T0010CompanyMaster? AssignedCmp { get; set; }

    public virtual T0040BankMaster? Bank { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0040BusinessSegment? BusinessSegment { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grd { get; set; }

    public virtual T0011Login? Login { get; set; }

    public virtual T0052HrmsPostedRecruitment? RecPost { get; set; }

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual T0050SubVertical? SubVertical { get; set; }

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0090HrmsResumeDocument> T0090HrmsResumeDocuments { get; set; } = new List<T0090HrmsResumeDocument>();

    public virtual ICollection<T0090HrmsResumeEarnDeduction> T0090HrmsResumeEarnDeductions { get; set; } = new List<T0090HrmsResumeEarnDeduction>();

    public virtual T0040VerticalSegment? Vertical { get; set; }
}
