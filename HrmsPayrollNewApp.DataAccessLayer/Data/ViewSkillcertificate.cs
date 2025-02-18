using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewSkillcertificate
{
    public decimal CertiId { get; set; }

    public string? CertificateName { get; set; }

    public string? CertificateCode { get; set; }

    public decimal? CatId { get; set; }

    public string? CatName { get; set; }

    public decimal? SubCatId { get; set; }

    public string? SubCatName { get; set; }

    public decimal? CmpId { get; set; }
}
