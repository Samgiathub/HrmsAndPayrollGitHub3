using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsTrainingMaster
{
    public decimal TrainingId { get; set; }

    public string? TrainingName { get; set; }

    public string? TrainingDescription { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? TrainingCategoryId { get; set; }

    public decimal? TrainingMcp { get; set; }

    public string TrainingCordinator { get; set; } = null!;

    public string TrainingDirector { get; set; } = null!;

    public decimal? TrainingType { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual ICollection<T0040TrainingInductionMaster> T0040TrainingInductionMasters { get; set; } = new List<T0040TrainingInductionMaster>();

    public virtual ICollection<T0050HrmsTrainingProviderMaster> T0050HrmsTrainingProviderMasters { get; set; } = new List<T0050HrmsTrainingProviderMaster>();

    public virtual ICollection<T0052HrmsTrainingCalenderYearly> T0052HrmsTrainingCalenderYearlies { get; set; } = new List<T0052HrmsTrainingCalenderYearly>();

    public virtual ICollection<T0055TrainingFaculty> T0055TrainingFaculties { get; set; } = new List<T0055TrainingFaculty>();

    public virtual ICollection<T0100HrmsTrainingApplication> T0100HrmsTrainingApplications { get; set; } = new List<T0100HrmsTrainingApplication>();

    public virtual ICollection<T0120HrmsTrainingApproval> T0120HrmsTrainingApprovals { get; set; } = new List<T0120HrmsTrainingApproval>();

    public virtual ICollection<T0150HrmsTrainingAnswer> T0150HrmsTrainingAnswers { get; set; } = new List<T0150HrmsTrainingAnswer>();

    public virtual ICollection<T0152HrmsTrainingQuestFinal> T0152HrmsTrainingQuestFinals { get; set; } = new List<T0152HrmsTrainingQuestFinal>();

    public virtual ICollection<T0160HrmsManagerFeedbackResponse> T0160HrmsManagerFeedbackResponses { get; set; } = new List<T0160HrmsManagerFeedbackResponse>();

    public virtual ICollection<T0160HrmsTrainingQuestionnaireResponse> T0160HrmsTrainingQuestionnaireResponses { get; set; } = new List<T0160HrmsTrainingQuestionnaireResponse>();
}
