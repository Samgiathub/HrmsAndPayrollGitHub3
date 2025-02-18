using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0152HrmsTrainingQuestFinal
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? TrainingQueId { get; set; }

    public decimal? TrainingAprId { get; set; }

    public decimal? TrainingId { get; set; }

    public decimal? Marks { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0160HrmsTrainingQuestionnaireResponse> T0160HrmsTrainingQuestionnaireResponses { get; set; } = new List<T0160HrmsTrainingQuestionnaireResponse>();

    public virtual T0040HrmsTrainingMaster? Training { get; set; }

    public virtual T0120HrmsTrainingApproval? TrainingApr { get; set; }

    public virtual T0150HrmsTrainingQuestionnaire? TrainingQue { get; set; }
}
