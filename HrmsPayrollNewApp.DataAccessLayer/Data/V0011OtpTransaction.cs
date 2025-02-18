using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0011OtpTransaction
{
    public decimal OtpId { get; set; }

    public decimal OtpTypeId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public int OtpCode { get; set; }

    public string? Email { get; set; }

    public string? MobileNo { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ExpiredDate { get; set; }

    public bool? IsVerified { get; set; }
}
