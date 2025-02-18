using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500CertificateskillMaster
{
    public decimal CertiId { get; set; }

    public decimal? CmpId { get; set; }

    public string? CertificateName { get; set; }

    public string? CertificateCode { get; set; }

    public decimal? CatId { get; set; }

    public decimal? SubCatId { get; set; }

    public decimal? SortingNo { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }
}
