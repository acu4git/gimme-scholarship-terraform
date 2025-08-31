# -------------------------------------------------------------
# AWS SES (Simple Email Service) の設定
# -------------------------------------------------------------

# 1. SESにドメイン登録
resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

# 2. ドメインのDKIM認証を有効化（メールの信頼性向上に必須）
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

# -------------------------------------------------------------
# Cloudflare DNS の設定
# -------------------------------------------------------------

# 1. SESのドメイン所有権を検証するためのTXTレコードを作成
# SES v2ではドメイン検証にTXTレコードが使われる．
resource "cloudflare_record" "ses_verification" {
  zone_id = var.cloudflare_zone_id
  name    = "_amazonses"
  type    = "TXT"
  content = aws_ses_domain_identity.main.verification_token
  ttl     = 3600

  # SESドメインIDが作成されるまで待機
  depends_on = [aws_ses_domain_identity.main]
}

# 2. SESのDKIM認証を検証するための3つのCNAMEレコードを作成
resource "cloudflare_record" "ses_dkim" {
  # for_eachを使い、aws_ses_domain_dkimが生成した3つのトークンに対してレコードをループ作成
  for_each = {
    dkim1 = aws_ses_domain_dkim.main.dkim_tokens[0]
    dkim2 = aws_ses_domain_dkim.main.dkim_tokens[1]
    dkim3 = aws_ses_domain_dkim.main.dkim_tokens[2]
  }

  zone_id = var.cloudflare_zone_id
  name    = "${each.key}._domainkey"
  type    = "CNAME"
  content = "${each.key}.dkim.amazonses.com"
  proxied = false # CNAMEレコードは「DNSのみ」にする必要がある
  ttl     = 3600

  # DKIMが有効化されるまで待機
  depends_on = [aws_ses_domain_dkim.main]
}
