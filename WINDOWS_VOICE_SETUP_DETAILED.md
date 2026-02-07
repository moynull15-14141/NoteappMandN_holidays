# Windows এ Noteapp এর জন্য মাইক্রোফোন পারমিশন সেটআপ

## সমস্যা
Windows এ Noteapp প্রথম চালু করার সময় automatic permission dialog আসে না।

## সমাধান

### পদ্ধতি ১: Windows Settings এ Manual এ Add করুন

#### ধাপ ১: Settings খুলুন
```
Windows Key + I চাপুন
অথবা
Settings > Privacy & Security > Microphone
```

#### ধাপ ২: Desktop apps access check করুন
1. **Privacy & Security > Microphone** এ যান
2. দেখুন "Allow apps to access your microphone" চালু আছে কিনা
3. যদি **Off** থাকে, **On** করুন

#### ধাপ ৩: Noteapp কে Add করুন
1. একই পেজে নিচে স্ক্রল করুন
2. "Allow desktop apps to access your microphone" খুঁজুন
3. সেখানে একটি **+** বোতাম থাকবে বা সরাসরি noteapp কে অনুসন্ধান করতে পারেন
4. Noteapp এ **On** করুন

#### ধাপ ৪: Speech Recognition ভাষা ইনস্টল করুন
1. **Settings > Time & Language > Speech** যান
2. নিশ্চিত করুন **Speech Language** এ English আছে
3. যদি না থাকে, **Add language** এ English ডাউনলোড করুন

---

### পদ্ধতি ২: Control Panel থেকে চেক করুন

1. **Control Panel > Sound > Recording** খুলুন
2. আপনার মাইক্রোফোন দেখা যাচ্ছে কিনা চেক করুন
3. যদি থাকে এবং **সবুজ চেক মার্ক** দেখা যায়, তাহলে ভালো
4. যদি লাল **X** থাকে, মাইক সংযুক্ত নেই

---

## Noteapp এ Voice Recording ব্যবহার করুন

সেটআপ করার পরে:

1. **Noteapp খুলুন**
2. **নতুন এন্ট্রি** ক্লিক করুন
3. **"Write your thoughts..." এর পাশে মাইক আইকন** ক্লিক করুন
4. **স্পষ্টভাবে কথা বলুন**
5. **আবার মাইক আইকন ক্লিক করুন** রেকর্ডিং বন্ধ করতে
6. আপনার **কথা টেক্সটে রূপান্তরিত হবে**

---

## সমস্যা সমাধান

### ১. Noteapp Settings এ দেখা যাচ্ছে না

**সমাধান:**
- Noteapp পুরো বন্ধ করুন
- সেটিংস পুনরায় খুলুন
- অনুসন্ধান করে Noteapp খুঁজে দিন

### ২. মাইক সংযুক্ত নেই

**চেক করুন:**
- মাইক physically connected আছে কিনা
- Device Manager এ মাইক দেখা যাচ্ছে কিনা
- মাইক ড্রাইভার আপডেট আছে কিনা

### ৩. Voice text এ রূপান্তরিত হচ্ছে না

**চেক করুন:**
- পটভূমিতে কম শব্দ থাকা উচিত
- স্পষ্টভাবে এবং ধীরে কথা বলুন
- English স্পিচ প্যাক ইনস্টল আছে কিনা

---

## কিভাবে Speech প্যাক ইনস্টল করবেন

1. **Settings > Time & Language > Speech** যান
2. **Speech language** খুঁজুন
3. যদি English এ ডাউনলোড আইকন থাকে, সেটা ক্লিক করুন
4. ডাউনলোড সম্পন্ন হওয়ার অপেক্ষা করুন

---

## টিপস

- **ধীরে এবং স্পষ্টভাবে** কথা বলুন
- **পটভূমিতে কম শব্দ** থাকা উচিত
- **মাইক গুণমান ভালো** হওয়া উচিত
- প্রথমবার সম্পূর্ণ সেটআপ করার পরে নিখুঁতভাবে কাজ করবে
