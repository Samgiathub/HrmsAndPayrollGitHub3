using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011OtpTransaction
{
    public decimal OtpId { get; set; }

    public decimal OtpTypeId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public int OtpCode { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ExpiredDate { get; set; }

    public bool? IsVerified { get; set; }

    public string? Email { get; set; }

    public string? MobileNo { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Otpmaster OtpType { get; set; } = null!;
}
