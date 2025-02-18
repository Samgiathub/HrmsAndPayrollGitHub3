using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0500EssBindSkillCertificate
{
    public decimal? CertiId { get; set; }

    public string? CertiName { get; set; }

    public decimal? ExpYears { get; set; }

    public decimal? IsTrainAttend { get; set; }

    public string? TrainCertiattach { get; set; }

    public decimal? IsExamAttend { get; set; }

    public string? ExamCertiattach { get; set; }

    public string? Descriptions { get; set; }

    public decimal CertiDetailsId { get; set; }
}
