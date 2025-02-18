using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0302PaymentProcessTravelDetail
{
    public decimal TravelPaymentId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal? TravelSetApprovalId { get; set; }

    public decimal PaymentProcessId { get; set; }

    public string? ProcessType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
