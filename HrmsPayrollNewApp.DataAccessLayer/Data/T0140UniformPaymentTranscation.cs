using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140UniformPaymentTranscation
{
    public decimal UniTranId { get; set; }

    public decimal? UniAprId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? UniId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? UniOpening { get; set; }

    public decimal? UniCredit { get; set; }

    public decimal? UniDebit { get; set; }

    public decimal? UniBalance { get; set; }

    public bool? UniFlag { get; set; }

    public decimal? FabricAmount { get; set; }

    public decimal? StitchingAmount { get; set; }
}
