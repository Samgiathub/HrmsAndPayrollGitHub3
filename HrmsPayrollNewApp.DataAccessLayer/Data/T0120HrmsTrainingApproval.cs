using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120HrmsTrainingApproval
{
    public decimal TrainingAprId { get; set; }

    public decimal TrainingAppId { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? TrainingId { get; set; }

    public DateTime? TrainingDate { get; set; }

    public string? Place { get; set; }

    public string? Faculty { get; set; }

    public decimal? TrainingProId { get; set; }

    public string? Description { get; set; }

    public decimal? TrainingCost { get; set; }

    public decimal? TrainingCostPerEmp { get; set; }

    public int? AprStatus { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? TrainingEndDate { get; set; }

    public decimal? TrainingType { get; set; }

    public int? TrainingLeaveType { get; set; }

    public int? NoOfDay { get; set; }

    public int? ImpactSalary { get; set; }

    public int? EmpFeedback { get; set; }

    public int? SupFeedback { get; set; }

    public string? Comments { get; set; }

    public string? BranchId { get; set; }

    public string? DeptId { get; set; }

    public string? DesigId { get; set; }

    public string? GrdId { get; set; }

    public string? TrainingCode { get; set; }

    public string? TrainingFromTime { get; set; }

    public string? TrainingToTime { get; set; }

    public byte? Lock { get; set; }

    public int BondMonth { get; set; }

    public string? Attachment { get; set; }

    public int? ManagerFeedbackDays { get; set; }

    public byte? PublishTraining { get; set; }

    public string? VideoUrl { get; set; }

    public decimal Latitude { get; set; }

    public decimal Longitude { get; set; }

    public string CategoryId { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0120HrmsTrainingAttachment> T0120HrmsTrainingAttachments { get; set; } = new List<T0120HrmsTrainingAttachment>();

    public virtual ICollection<T0130HrmsTrainingEmployeeDetail> T0130HrmsTrainingEmployeeDetails { get; set; } = new List<T0130HrmsTrainingEmployeeDetail>();

    public virtual ICollection<T0150EmpTrainingInoutRecord> T0150EmpTrainingInoutRecords { get; set; } = new List<T0150EmpTrainingInoutRecord>();

    public virtual ICollection<T0150HrmsTrainingAnswer> T0150HrmsTrainingAnswers { get; set; } = new List<T0150HrmsTrainingAnswer>();

    public virtual ICollection<T0152HrmsTrainingQuestFinal> T0152HrmsTrainingQuestFinals { get; set; } = new List<T0152HrmsTrainingQuestFinal>();

    public virtual ICollection<T0160HrmsManagerFeedbackResponse> T0160HrmsManagerFeedbackResponses { get; set; } = new List<T0160HrmsManagerFeedbackResponse>();

    public virtual ICollection<T0160HrmsTrainingQuestionnaireResponse> T0160HrmsTrainingQuestionnaireResponses { get; set; } = new List<T0160HrmsTrainingQuestionnaireResponse>();

    public virtual T0040HrmsTrainingMaster? Training { get; set; }

    public virtual T0050HrmsTrainingProviderMaster? TrainingPro { get; set; }
}
