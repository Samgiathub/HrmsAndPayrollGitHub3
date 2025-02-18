using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetSkillCertificateDetail
{
    public string? SkillLevel { get; set; }

    public decimal CertiDetailId { get; set; }

    public decimal? CertiId { get; set; }

    public string? Descriptions { get; set; }

    public decimal? ExpYears { get; set; }

    public string? CertificateName { get; set; }

    public decimal? CmpId { get; set; }
}
