using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140EmpGpfTransaction
{
    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? GpfOpening { get; set; }

    public decimal? GpfCredit { get; set; }

    public decimal? GpfDebit { get; set; }

    public decimal? GpfClosing { get; set; }

    public decimal? GpfPosting { get; set; }

    public DateTime? SystemDate { get; set; }
}
