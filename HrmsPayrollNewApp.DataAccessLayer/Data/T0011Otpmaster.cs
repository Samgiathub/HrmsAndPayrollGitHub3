using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011Otpmaster
{
    public decimal OtpTypeId { get; set; }

    public string OtpType { get; set; } = null!;

    public string OtpTypeCode { get; set; } = null!;

    public virtual ICollection<T0011OtpTransaction> T0011OtpTransactions { get; set; } = new List<T0011OtpTransaction>();
}
