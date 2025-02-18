using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120HrmsTrainingAttachment
{
    public decimal TrainingAttachId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TrainingAprId { get; set; }

    public string? Attachment { get; set; }

    public string? VideoUrl { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0120HrmsTrainingApproval TrainingApr { get; set; } = null!;
}
